const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// 수요 예측 계산 함수
function calculateRecommendedNeed(minQuantity, weatherMain, isHoliday) {
  let demandBoost = 0;

  if (['clear', 'hot'].includes(weatherMain)) demandBoost += 2;
  else if (['rain', 'snow'].includes(weatherMain)) demandBoost += 0;
  else demandBoost += 1;

  if (isHoliday) demandBoost += 2;

  return minQuantity + demandBoost;
}

// 앱에서 호출 가능한 Cloud Function
exports.generateStockRecommendations = functions.https.onRequest(async (req, res) => {
  const storeId = req.body.storeId;
  const weatherMain = req.body.weatherMain || 'cloudy';
  const isHoliday = req.body.isHoliday === true;

  console.log('📥 generateStockRecommendations called');
  console.log('➡️ storeId:', storeId);
  console.log('➡️ weatherMain:', weatherMain);
  console.log('➡️ isHoliday:', isHoliday);

  if (!storeId) {
    console.error('❌ storeId is missing');
    return res.status(400).json({ error: 'storeId is required' });
  }

  try {
    const stockSnap = await db.collection('stocks').doc(storeId).collection('items').get();
    const templateSnap = await db.collection('orderTemplates').get();

    console.log('📦 stock items count:', stockSnap.size);
    console.log('📄 template items count:', templateSnap.size);

    const nameMap = {};
    templateSnap.forEach(doc => {
      nameMap[doc.id] = doc.data().name || doc.id;
    });

    const normalizeName = (name) => name.replace(/\s+/g, '').toLowerCase(); // 공백 제거 + 소문자화

    const seenNames = new Set(); // ✅ 중복 제거용 Set
    const results = [];

    for (const doc of stockSnap.docs) {
      const data = doc.data();
      const id = doc.id;
      const quantity = data.quantity || 0;
      const min = data.minQuantity || 0;

      const name = nameMap[id] || id;
      const normalized = normalizeName(name);

      if (seenNames.has(normalized)) {
        console.log(`⚠️ 중복된 품목(${name}) 스킵됨`);
        continue;
      }
      seenNames.add(normalized);

      const predictedNeed = calculateRecommendedNeed(min, weatherMain, isHoliday);
      const recommendedExtra = Math.max(0, predictedNeed - quantity);

      results.push({
        name,
        quantity,
        minQuantity: min,
        predictedNeed,
        recommendedExtra,
      });
    }

    console.log('✅ 중복 제거 후 결과 수:', results.length);

    await db.collection('recommendations').doc(storeId).set({
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      weatherMain,
      isHoliday,
      items: results,
    });

    console.log('✅ 추천 결과 저장 완료');

    res.status(200).json({ message: '추천 저장 완료', items: results });
  } catch (error) {
    console.error('❌ 함수 실행 중 오류:', error);
    return res.status(500).json({ error: 'Failed to generate stock recommendations' });
  }
});
