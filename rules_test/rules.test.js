// Run with: firebase emulators:exec --only firestore "npm test --prefix rules_test"
const { test, before, after, beforeEach } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, getDocs, query, where,
  arrayUnion, arrayRemove,
} = require('firebase/firestore');

let env;
const GM = 'gm1', P1 = 'p1', P2 = 'p2', OUT = 'outsider';
const db = (uid) => env.authenticatedContext(uid).firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'rules-test',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'storage.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 9199,
    },
  });
});
after(async () => env && env.cleanup());

// camp1: GM gm1, member p1 (shared char1). code ABC234.
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const f = ctx.firestore();
    await setDoc(doc(f, 'characters/char1'), { userId: P1, name: 'A', sharedGmIds: [GM] });
    await setDoc(doc(f, 'characters/char2'), { userId: P2, name: 'B' });
    await setDoc(doc(f, 'campaigns/camp1'), {
      name: 'C', gmId: GM, joinCode: 'ABC234', memberIds: [P1],
    });
    await setDoc(doc(f, 'campaigns/camp1/shared/char1'), {
      characterId: 'char1', ownerId: P1,
    });
    await setDoc(doc(f, 'campaignCodes/ABC234'), { campaignId: 'camp1', gmId: GM, name: 'C' });
  });
});

// ---- characters ----
test('GM can read a shared character', () =>
  assertSucceeds(getDoc(doc(db(GM), 'characters/char1'))));
test('GM cannot write a shared character', async () => {
  await assertFails(updateDoc(doc(db(GM), 'characters/char1'), { name: 'X' }));
  await assertFails(deleteDoc(doc(db(GM), 'characters/char1')));
});
test('GM cannot read an unshared character', () =>
  assertFails(getDoc(doc(db(GM), 'characters/char2'))));
test('other player cannot read a shared character', () =>
  assertFails(getDoc(doc(db(P2), 'characters/char1'))));
test('outsider cannot read anything', () =>
  assertFails(getDoc(doc(db(OUT), 'characters/char1'))));
test('unauthenticated cannot read a character', () =>
  assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'characters/char1'))));
test('owner can still read/update own character', async () => {
  await assertSucceeds(getDoc(doc(db(P1), 'characters/char1')));
  await assertSucceeds(updateDoc(doc(db(P1), 'characters/char1'), { name: 'New' }));
});
test('owner can add a GM to sharedGmIds', () =>
  assertSucceeds(updateDoc(doc(db(P2), 'characters/char2'), { sharedGmIds: arrayUnion(GM) })));
test('non-owner cannot add themselves to sharedGmIds', () =>
  assertFails(updateDoc(doc(db(OUT), 'characters/char1'), { sharedGmIds: arrayUnion(OUT) })));

// ---- campaigns ----
test('GM and members can read campaign; outsiders cannot', async () => {
  await assertSucceeds(getDoc(doc(db(GM), 'campaigns/camp1')));
  await assertSucceeds(getDoc(doc(db(P1), 'campaigns/camp1')));
  await assertFails(getDoc(doc(db(OUT), 'campaigns/camp1')));
});
test('cannot create a campaign as someone else', () =>
  assertFails(setDoc(doc(db(OUT), 'campaigns/evil'), { gmId: GM, memberIds: [] })));
test('can create own campaign', () =>
  assertSucceeds(setDoc(doc(db(OUT), 'campaigns/mine'), { gmId: OUT, memberIds: [] })));
test('GM lists own campaigns; member lists joined', async () => {
  await assertSucceeds(getDocs(query(collection(db(GM), 'campaigns'), where('gmId', '==', GM))));
  await assertSucceeds(getDocs(query(collection(db(P1), 'campaigns'), where('memberIds', 'array-contains', P1))));
});
test('cannot list other people\'s campaigns', () =>
  assertFails(getDocs(query(collection(db(OUT), 'campaigns'), where('gmId', '==', GM)))));
test('new player can add only themselves to memberIds', async () => {
  await assertSucceeds(updateDoc(doc(db(P2), 'campaigns/camp1'), { memberIds: arrayUnion(P2) }));
});
test('player cannot add someone else or change other fields', async () => {
  await assertFails(updateDoc(doc(db(P2), 'campaigns/camp1'), { memberIds: arrayUnion(OUT) }));
  await assertFails(updateDoc(doc(db(P2), 'campaigns/camp1'), { memberIds: arrayUnion(P2), name: 'Hacked' }));
  await assertFails(updateDoc(doc(db(P2), 'campaigns/camp1'), { gmId: P2 }));
});
test('player cannot remove another member', () =>
  assertFails(updateDoc(doc(db(P2), 'campaigns/camp1'), { memberIds: arrayRemove(P1) })));
test('player can remove themselves', () =>
  assertSucceeds(updateDoc(doc(db(P1), 'campaigns/camp1'), { memberIds: arrayRemove(P1) })));
test('GM can remove a member and rename', async () => {
  await assertSucceeds(updateDoc(doc(db(GM), 'campaigns/camp1'), { memberIds: arrayRemove(P1) }));
  await assertSucceeds(updateDoc(doc(db(GM), 'campaigns/camp1'), { name: 'Renamed' }));
});
test('only GM can delete campaign', async () => {
  await assertFails(deleteDoc(doc(db(P1), 'campaigns/camp1')));
  await assertSucceeds(deleteDoc(doc(db(GM), 'campaigns/camp1')));
});

// ---- shared subcollection ----
test('GM, owner and members read shared; outsider cannot', async () => {
  await assertSucceeds(getDoc(doc(db(GM), 'campaigns/camp1/shared/char1')));
  await assertSucceeds(getDoc(doc(db(P1), 'campaigns/camp1/shared/char1')));
  await assertFails(getDoc(doc(db(OUT), 'campaigns/camp1/shared/char1')));
});
test('player can share own character after joining; outsider cannot', async () => {
  await assertFails(setDoc(doc(db(P2), 'campaigns/camp1/shared/char2'), { characterId: 'char2', ownerId: P2 }));
  await assertSucceeds(updateDoc(doc(db(P2), 'campaigns/camp1'), { memberIds: arrayUnion(P2) }));
  await assertSucceeds(setDoc(doc(db(P2), 'campaigns/camp1/shared/char2'), { characterId: 'char2', ownerId: P2 }));
});
test('player cannot share someone else\'s character', () =>
  assertFails(setDoc(doc(db(P2), 'campaigns/camp1/shared/char1'), { characterId: 'char1', ownerId: P2 })));
test('player cannot spoof ownerId', () =>
  assertFails(setDoc(doc(db(P2), 'campaigns/camp1/shared/char2'), { characterId: 'char2', ownerId: P1 })));
test('owner and GM can delete shared entry; others cannot', async () => {
  await assertFails(deleteDoc(doc(db(P2), 'campaigns/camp1/shared/char1')));
  await assertSucceeds(deleteDoc(doc(db(P1), 'campaigns/camp1/shared/char1')));
  await env.withSecurityRulesDisabled((c) =>
    setDoc(doc(c.firestore(), 'campaigns/camp1/shared/char1'), { characterId: 'char1', ownerId: P1 }));
  await assertSucceeds(deleteDoc(doc(db(GM), 'campaigns/camp1/shared/char1')));
});

// ---- join codes ----
test('any signed-in user can get a code but not list codes', async () => {
  await assertSucceeds(getDoc(doc(db(OUT), 'campaignCodes/ABC234')));
  await assertFails(getDocs(collection(db(OUT), 'campaignCodes')));
});
test('unauthenticated cannot get a code', () =>
  assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), 'campaignCodes/ABC234'))));
test('only GM may create/delete their code', async () => {
  await assertFails(setDoc(doc(db(OUT), 'campaignCodes/ZZZ999'), { campaignId: 'x', gmId: GM }));
  await assertSucceeds(setDoc(doc(db(OUT), 'campaignCodes/ZZZ999'), { campaignId: 'x', gmId: OUT }));
  await assertFails(deleteDoc(doc(db(OUT), 'campaignCodes/ABC234')));
  await assertSucceeds(deleteDoc(doc(db(GM), 'campaignCodes/ABC234')));
});
test('codes cannot be overwritten by another user', () =>
  assertFails(setDoc(doc(db(OUT), 'campaignCodes/ABC234'), { campaignId: 'evil', gmId: OUT })));

// ---- end-to-end flows mirroring CampaignService ----
const { runTransaction, serverTimestamp, limit } = require('firebase/firestore');

async function join(uid, charId, code, gm, campId) {
  const f = db(uid);
  await getDoc(doc(f, 'campaignCodes', code));
  await getDoc(doc(f, 'characters', charId));
  await updateDoc(doc(f, 'characters', charId), { sharedGmIds: arrayUnion(gm) });
  await updateDoc(doc(f, 'campaigns', campId), { memberIds: arrayUnion(uid) });
  await setDoc(doc(f, 'campaigns', campId, 'shared', charId),
    { characterId: charId, ownerId: uid, sharedAt: serverTimestamp() });
}

test('flow: GM creates campaign (transaction) then player joins, GM reads live', async () => {
  const g = db('gmX');
  const campRef = doc(collection(g, 'campaigns'));
  await assertSucceeds(runTransaction(g, async (tx) => {
    const codeRef = doc(g, 'campaignCodes', 'NEW234');
    const ex = await tx.get(codeRef);
    if (ex.exists()) throw new Error('taken');
    tx.set(campRef, { name: 'N', gmId: 'gmX', joinCode: 'NEW234', memberIds: [] });
    tx.set(codeRef, { campaignId: campRef.id, gmId: 'gmX', name: 'N' });
  }));
  await env.withSecurityRulesDisabled((c) =>
    setDoc(doc(c.firestore(), 'characters/c9'), { userId: P2, name: 'Z' }));
  await assertSucceeds(join(P2, 'c9', 'NEW234', 'gmX', campRef.id));
  await assertSucceeds(getDoc(doc(db('gmX'), 'characters/c9')));
  await assertSucceeds(getDocs(collection(db('gmX'), 'campaigns', campRef.id, 'shared')));
  await assertSucceeds(getDocs(collection(db(P2), 'campaigns', campRef.id, 'shared')));
});

test('flow: player leaves; GM loses character access and membership is dropped', async () => {
  const f = db(P1);
  await assertSucceeds(deleteDoc(doc(f, 'campaigns/camp1/shared/char1')));
  await assertSucceeds(getDocs(query(collection(f, 'campaigns/camp1/shared'), where('ownerId', '==', P1), limit(1))));
  await assertSucceeds(updateDoc(doc(f, 'characters/char1'), { sharedGmIds: arrayRemove(GM) }));
  await assertSucceeds(updateDoc(doc(f, 'campaigns/camp1'), { memberIds: arrayRemove(P1) }));
  await assertFails(getDoc(doc(db(GM), 'characters/char1')));
  await assertFails(getDoc(doc(db(P1), 'campaigns/camp1')));
});

test('flow: GM removes a player character and deletes the campaign', async () => {
  const g = db(GM);
  await assertSucceeds(deleteDoc(doc(g, 'campaigns/camp1/shared/char1')));
  await assertSucceeds(getDocs(query(collection(g, 'campaigns/camp1/shared'), where('ownerId', '==', P1), limit(1))));
  await assertSucceeds(updateDoc(doc(g, 'campaigns/camp1'), { memberIds: arrayRemove(P1) }));
  await assertSucceeds(deleteDoc(doc(g, 'campaignCodes/ABC234')));
  await assertSucceeds(deleteDoc(doc(g, 'campaigns/camp1')));
});

test('flow: member lists their joined campaigns query', () =>
  assertSucceeds(getDocs(query(collection(db(P1), 'campaigns'), where('memberIds', 'array-contains', P1)))));

test('security: stranger cannot self-join a campaign with an unshared character they do not own', async () => {
  await assertFails(setDoc(doc(db(OUT), 'campaigns/camp1/shared/char1'), { characterId: 'char1', ownerId: OUT }));
});

test('security: GM of campaign A cannot read characters shared only to campaign B', async () => {
  await env.withSecurityRulesDisabled(async (c) => {
    const f = c.firestore();
    await setDoc(doc(f, 'campaigns/campB'), { name: 'B', gmId: 'gmB', memberIds: [P2] });
    await setDoc(doc(f, 'characters/char3'), { userId: P2, sharedGmIds: ['gmB'] });
  });
  await assertFails(getDoc(doc(db(GM), 'characters/char3')));
  await assertSucceeds(getDoc(doc(db('gmB'), 'characters/char3')));
});

// ---- feed, dice and uploads ----
const { addDoc } = require('firebase/firestore');
const { ref, uploadBytes, getBytes, deleteObject } = require('firebase/storage');
const feed = (uid) => collection(db(uid), 'campaigns/camp1/feed');
const base = (uid, extra) => ({
  authorId: uid, authorName: 'N', text: '', createdAt: serverTimestamp(), ...extra,
});
const roll = (uid, kind, dice, total) =>
  base(uid, { type: 'roll', roll: { kind, dice, total } });

test('feed: GM and member can post messages; outsider and other player cannot', async () => {
  await assertSucceeds(addDoc(feed(GM), base(GM, { type: 'message', text: 'hi' })));
  await assertSucceeds(addDoc(feed(P1), base(P1, { type: 'message', text: 'hi' })));
  await assertFails(addDoc(feed(OUT), base(OUT, { type: 'message', text: 'hi' })));
  await assertFails(addDoc(feed(P2), base(P2, { type: 'message', text: 'hi' })));
});
test('feed: valid 1D10 and 2D10 rolls succeed', async () => {
  await assertSucceeds(addDoc(feed(P1), roll(P1, '1d10', [7], 7)));
  await assertSucceeds(addDoc(feed(P1), roll(P1, '1d10', [1], 1)));
  await assertSucceeds(addDoc(feed(P1), roll(P1, '1d10', [10], 10)));
  await assertSucceeds(addDoc(feed(GM), roll(GM, '2d10', [10, 7], 17)));
  await assertSucceeds(addDoc(feed(GM), roll(GM, '2d10', [1, 1], 2)));
});
test('feed: rigged or malformed rolls are rejected', async () => {
  await assertFails(addDoc(feed(P1), roll(P1, '1d10', [11], 11)));
  await assertFails(addDoc(feed(P1), roll(P1, '1d10', [0], 0)));
  await assertFails(addDoc(feed(P1), roll(P1, '1d10', [5], 9)));
  await assertFails(addDoc(feed(P1), roll(P1, '1d10', [5, 5], 10)));
  await assertFails(addDoc(feed(P1), roll(P1, '2d10', [11, 1], 12)));
  await assertFails(addDoc(feed(P1), roll(P1, '2d10', [10], 10)));
  await assertFails(addDoc(feed(P1), roll(P1, '2d10', [10, 10], 21)));
  await assertFails(addDoc(feed(P1), roll(P1, '2d10', [1.5, 2], 3.5)));
  await assertFails(addDoc(feed(P1), roll(P1, '3d6', [1, 2, 3], 6)));
});
test('feed: cannot post as someone else, with fake time, or extra fields', async () => {
  await assertFails(addDoc(feed(P1), base(GM, { type: 'message', text: 'x' })));
  await assertFails(addDoc(feed(P1), { ...base(P1, { type: 'message', text: 'x' }), createdAt: new Date(2020, 1, 1) }));
  await assertFails(addDoc(feed(P1), base(P1, { type: 'message', text: 'x', admin: true })));
  await assertFails(addDoc(feed(P1), base(P1, { type: 'message', text: '' })));
  await assertFails(addDoc(feed(P1), base(P1, { type: 'message', text: 'x'.repeat(501) })));
});
test('feed: file posts must be allowed types under the author\'s own path', async () => {
  const file = (uid, over) => base(uid, {
    type: 'file', fileUrl: 'https://firebasestorage.googleapis.com/x', fileName: 'a.png', contentType: 'image/png',
    storagePath: `campaign_files/camp1/${uid}/p_a.png`, ...over,
  });
  await assertSucceeds(addDoc(feed(P1), file(P1, {})));
  await assertSucceeds(addDoc(feed(P1), file(P1, { contentType: 'application/pdf', fileName: 'a.pdf' })));
  await assertFails(addDoc(feed(P1), file(P1, { contentType: 'application/x-msdownload' })));
  await assertFails(addDoc(feed(P1), file(P1, { storagePath: `campaign_files/camp1/${GM}/p_a.png` })));
  await assertFails(addDoc(feed(P1), file(P1, { storagePath: `campaign_files/other/${P1}/p_a.png` })));
});
test('feed: posts can be read by participants only, never edited', async () => {
  const r = await addDoc(feed(P1), roll(P1, '1d10', [4], 4));
  const id = r.id;
  await assertSucceeds(getDoc(doc(db(GM), 'campaigns/camp1/feed', id)));
  await assertSucceeds(getDoc(doc(db(P1), 'campaigns/camp1/feed', id)));
  await assertFails(getDoc(doc(db(OUT), 'campaigns/camp1/feed', id)));
  await assertFails(updateDoc(doc(db(P1), 'campaigns/camp1/feed', id), { roll: { kind: '1d10', dice: [10], total: 10 } }));
  await assertFails(updateDoc(doc(db(GM), 'campaigns/camp1/feed', id), { text: 'edit' }));
  await assertSucceeds(getDocs(query(collection(db(P1), 'campaigns/camp1/feed'))));
  await assertFails(getDocs(query(collection(db(OUT), 'campaigns/camp1/feed'))));
});
test('feed: author or GM can delete; other member cannot', async () => {
  await env.withSecurityRulesDisabled(async (c) => {
    const f = c.firestore();
    await setDoc(doc(f, 'campaigns/camp1'), { name: 'C', gmId: GM, joinCode: 'ABC234', memberIds: [P1, P2] });
    await setDoc(doc(f, 'campaigns/camp1/feed/a'), { authorId: P1, type: 'message', text: 'x' });
    await setDoc(doc(f, 'campaigns/camp1/feed/b'), { authorId: P1, type: 'message', text: 'x' });
  });
  await assertFails(deleteDoc(doc(db(P2), 'campaigns/camp1/feed/a')));
  await assertSucceeds(deleteDoc(doc(db(P1), 'campaigns/camp1/feed/a')));
  await assertSucceeds(deleteDoc(doc(db(GM), 'campaigns/camp1/feed/b')));
});

const stor = (uid) => env.authenticatedContext(uid).storage();
const png = () => new Uint8Array([137, 80, 78, 71]);
test('storage: member uploads own png/pdf; GM and members read', async () => {
  const r = ref(stor(P1), `campaign_files/camp1/${P1}/a.png`);
  await assertSucceeds(uploadBytes(r, png(), { contentType: 'image/png' }));
  await assertSucceeds(uploadBytes(ref(stor(P1), `campaign_files/camp1/${P1}/b.pdf`), png(), { contentType: 'application/pdf' }));
  await assertSucceeds(getBytes(ref(stor(GM), `campaign_files/camp1/${P1}/a.png`)));
  await assertSucceeds(getBytes(ref(stor(P1), `campaign_files/camp1/${P1}/a.png`)));
});
test('storage: signed-out users cannot read; others cannot upload to another user folder', async () => {
  await env.withSecurityRulesDisabled((c) =>
    uploadBytes(ref(c.storage(), `campaign_files/camp1/${P1}/a.png`), png(), { contentType: 'image/png' }));
  await assertFails(uploadBytes(ref(stor(OUT), `campaign_files/camp1/${P1}/a.png`), png(), { contentType: 'image/png' }));
  await assertFails(getBytes(ref(env.unauthenticatedContext().storage(), `campaign_files/camp1/${P1}/a.png`)));
});
test('storage: bad type, oversize, or someone else\'s folder is rejected', async () => {
  await assertFails(uploadBytes(ref(stor(P1), `campaign_files/camp1/${P1}/a.exe`), png(), { contentType: 'application/x-msdownload' }));
  await assertFails(uploadBytes(ref(stor(P1), `campaign_files/camp1/${P1}/a.html`), png(), { contentType: 'text/html' }));
  await assertFails(uploadBytes(ref(stor(P1), `campaign_files/camp1/${P1}/big.png`), new Uint8Array(5 * 1024 * 1024 + 1), { contentType: 'image/png' }));
  await assertSucceeds(uploadBytes(ref(stor(P1), `campaign_files/camp1/${P1}/ok.png`), new Uint8Array(5 * 1024 * 1024), { contentType: 'image/png' }));
  await assertFails(uploadBytes(ref(stor(P1), `campaign_files/camp1/${GM}/a.png`), png(), { contentType: 'image/png' }));
});
test('storage: uploader or stamped GM can delete', async () => {
  await env.withSecurityRulesDisabled(async (c) => {
    await setDoc(doc(c.firestore(), 'campaigns/camp1'), { name: 'C', gmId: GM, joinCode: 'ABC234', memberIds: [P1, P2] });
    await uploadBytes(ref(c.storage(), `campaign_files/camp1/${P1}/a.png`), png(), { contentType: 'image/png' });
    await uploadBytes(ref(c.storage(), `campaign_files/camp1/${P1}/b.png`), png(), { contentType: 'image/png' });
    await uploadBytes(ref(c.storage(), `campaign_files/camp1/${P1}/c.png`), png(), { contentType: 'image/png', customMetadata: { gmId: GM } });
  });
  await assertFails(deleteObject(ref(stor(P2), `campaign_files/camp1/${P1}/a.png`)));
  await assertSucceeds(deleteObject(ref(stor(P1), `campaign_files/camp1/${P1}/a.png`)));
  await assertFails(deleteObject(ref(stor(GM), `campaign_files/camp1/${P1}/b.png`)));
  await assertSucceeds(deleteObject(ref(stor(GM), `campaign_files/camp1/${P1}/c.png`)));
  await assertFails(deleteObject(ref(stor(P2), `campaign_files/camp1/${P1}/c.png`)));
});
test('GM can drop only their own access to a character', async () => {
  const c = doc(db(GM), 'characters/char1');
  await assertFails(updateDoc(c, { name: 'X' }));
  await assertFails(updateDoc(c, { sharedGmIds: [GM, OUT] }));
  await assertFails(updateDoc(doc(db(GM), 'characters/char2'), { sharedGmIds: [] }));
  await assertSucceeds(updateDoc(c, { sharedGmIds: [] }));
  await assertFails(getDoc(c));
});

// ---- uploaded sheet entries (kind: 'file') ----
const sheet = (uid, extra = {}) => ({
  kind: 'file', characterId: 's1', ownerId: uid, characterName: 'NPC',
  fileUrl: 'https://firebasestorage.googleapis.com/x', contentType: 'application/pdf',
  storagePath: `campaign_files/camp1/${uid}/sheet_s1_a.pdf`, ...extra,
});
test('sheet: GM and player can add a PDF/image sheet', async () => {
  await assertSucceeds(setDoc(doc(db(GM), 'campaigns/camp1/shared/s1'), sheet(GM)));
  await assertSucceeds(setDoc(doc(db(P1), 'campaigns/camp1/shared/s2'), sheet(P1, { contentType: 'image/png' })));
});
test('sheet: rejects bad type, spoofed owner or foreign path', async () => {
  await assertFails(setDoc(doc(db(P1), 'campaigns/camp1/shared/s3'), sheet(P1, { contentType: 'application/msword' })));
  await assertFails(setDoc(doc(db(P1), 'campaigns/camp1/shared/s4'), sheet(GM)));
  await assertFails(setDoc(doc(db(P1), 'campaigns/camp1/shared/s5'), sheet(P1, { storagePath: `campaign_files/camp1/${GM}/a.pdf` })));
  await assertFails(setDoc(doc(db(P1), 'campaigns/camp1/shared/s6'), sheet(P1, { storagePath: `campaign_files/other/${P1}/a.pdf` })));
});
test('sheet: outsider cannot add; non-owner member cannot delete', async () => {
  await assertFails(setDoc(doc(db(OUT), 'campaigns/camp1/shared/s7'), sheet(OUT)));
  await env.withSecurityRulesDisabled((c) => setDoc(doc(c.firestore(), 'campaigns/camp1/shared/s8'), sheet(P1)));
  await assertFails(deleteDoc(doc(db(P2), 'campaigns/camp1/shared/s8')));
  await assertSucceeds(deleteDoc(doc(db(GM), 'campaigns/camp1/shared/s8')));
});

// ---- pressure: hijack, links, extra fields ----
const FB = 'https://firebasestorage.googleapis.com/v0/b/x/o/y?alt=media';
test('pressure: member cannot overwrite another member sheet or character entry', async () => {
  await env.withSecurityRulesDisabled((c) => setDoc(doc(c.firestore(), 'campaigns/camp1/shared/s9'), sheet(P1, { fileUrl: FB })));
  await env.withSecurityRulesDisabled((c) => updateDoc(doc(c.firestore(), 'campaigns/camp1'), { memberIds: arrayUnion(P2) }));
  await assertFails(setDoc(doc(db(P2), 'campaigns/camp1/shared/s9'), sheet(P2, { fileUrl: FB })));
  await assertFails(setDoc(doc(db(P2), 'campaigns/camp1/shared/char1'), sheet(P2, { fileUrl: FB })));
  await assertSucceeds(setDoc(doc(db(P1), 'campaigns/camp1/shared/s9'), sheet(P1, { fileUrl: FB, characterName: 'Renamed' })));
});
test('pressure: only Firebase Storage links accepted for sheets and feed files', async () => {
  for (const bad of ['javascript:alert(1)', 'https://evil.example/x.pdf', 'http://firebasestorage.googleapis.com/x', '']) {
    await assertFails(setDoc(doc(db(GM), 'campaigns/camp1/shared/b1'), sheet(GM, { fileUrl: bad })));
    await assertFails(addDoc(feed(P1), { ...base(P1, { type: 'file', text: '', fileName: 'a.pdf', contentType: 'application/pdf',
      fileUrl: bad, storagePath: `campaign_files/camp1/${P1}/a.pdf` }) }));
  }
  await assertSucceeds(setDoc(doc(db(GM), 'campaigns/camp1/shared/b2'), sheet(GM, { fileUrl: FB })));
});
test('pressure: sheet entries reject extra fields and oversize names', async () => {
  await assertFails(setDoc(doc(db(GM), 'campaigns/camp1/shared/b3'), sheet(GM, { fileUrl: FB, junk: 'x' })));
  await assertFails(setDoc(doc(db(GM), 'campaigns/camp1/shared/b4'), sheet(GM, { fileUrl: FB, characterName: 'x'.repeat(101) })));
});
