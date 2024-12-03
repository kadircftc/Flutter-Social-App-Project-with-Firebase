

const functions = require('firebase-functions');

const admin = require('firebase-admin');

admin.initializeApp();

exports.takipGerceklesti = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onCreate(async (snapshot, context) => {
   const takipEdilenId = context.params.takipEdilenId;
   const takipEdenId = context.params.takipEdenKullaniciId;

   const gonderilerSnapshot = await admin.firestore().collection("posts").doc(takipEdilenId).collection("usersPosts").get();

   gonderilerSnapshot.forEach((doc) => {
      if (doc.exists) {
         const gonderiId = doc.id;
         const gonderiData = doc.data();

         admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(gonderiData);
      }
   });

   
});

exports.takiptenCikildi = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipEdenKullaniciId}').onDelete(async (snapshot, context) => {
   const takipEdilenId = context.params.takipEdilenId;
   const takipEdenId = context.params.takipEdenKullaniciId;

   const gonderilerSnapshot = await admin.firestore().collection("akislar").doc(takipEdenId).collection("kullaniciAkisGonderileri").where("postedId", "==", takipEdilenId).get();

   gonderilerSnapshot.forEach((doc) => {
      if (doc.exists) {
         doc.ref.delete();
      }
   });
});


exports.yeniGonderiEklendi = functions.firestore.document('posts/{takipEdilenKullaniciId}/usersPosts/{gonderiId}').onCreate(async (snapshot, context) => {
   const takipEdilenId = context.params.takipEdilenKullaniciId;
   const gonderiId = context.params.gonderiId;
   const yeniGonderiData = snapshot.data();

   const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

   takipcilerSnapshot.forEach(doc => {

      const takipciId = doc.id;
      admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).set(yeniGonderiData);

   });
});

exports.gonderiGuncellendi = functions.firestore.document('posts/{takipEdilenKullaniciId}/usersPosts/{gonderiId}').onUpdate(async (snapshot, context) => {
   const takipEdilenId = context.params.takipEdilenKullaniciId;
   const gonderiId = context.params.gonderiId;
   const guncellenmisGonderiData = snapshot.after.data();

   const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

   takipcilerSnapshot.forEach(doc => {

      const takipciId = doc.id;
      admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).update(guncellenmisGonderiData);

   });
});

exports.gonderiSilindi = functions.firestore.document('posts/{takipEdilenKullaniciId}/usersPosts/{gonderiId}').onDelete(async (snapshot, context) => {
   const takipEdilenId = context.params.takipEdilenKullaniciId;
   const gonderiId = context.params.gonderiId;


   const takipcilerSnapshot = await admin.firestore().collection("takipciler").doc(takipEdilenId).collection("kullanicininTakipcileri").get();

   takipcilerSnapshot.forEach(doc => {

      const takipciId = doc.id;
      admin.firestore().collection("akislar").doc(takipciId).collection("kullaniciAkisGonderileri").doc(gonderiId).delete();

   });
});


exports.emailhasChanged = functions.firestore.document('users/{userId}').onUpdate(async (snap, context) => {
   console.log('Trigger executed');
   const oldData = snap.before.data();
   const newData = snap.after.data();
   if (oldData.email != newData.email) {
      var payload = {
         notification: {
            title: 'your email changed now',
            body: oldData.email + 'replaced to' + newData.email,
            sound: 'beep',
            channel_id: 'HUNGRY',
            android_channel_id: 'HUNGRY',
            priority: 'high',
         }
      }
      try {
         const response = await admin.messaging().sendToDevice(newData.token, payload);
         console.log('Notification sent successfully:', response);
      } catch (error) {
         console.error('Error sending notification:', error);
      }

   }
});

exports.newFollower = functions.firestore.document('takipciler/{takipEdilenId}/kullanicininTakipcileri/{takipciId}').onCreate(async (snapshot, context) => {
  const takipEdilenId = context.params.takipEdilenId;
  const takipciId = context.params.takipciId;

  // Get the follower's username
  const takipciSnapshot = await admin.firestore().collection('users').doc(takipciId).get();
  const takipciUsername = takipciSnapshot.data().userName;

  // Get the followed user's token
  const takipEdilenSnapshot = await admin.firestore().collection('users').doc(takipEdilenId).get();
  const takipEdilenToken = takipEdilenSnapshot.data().token;

  if (takipEdilenToken) {
    const payload = {
      notification: {
        title: 'Yeni Takipçi',
        body: `${takipciUsername} sizi takip etmeye başladı`,
        sound: 'default',
        channel_id: 'FOLLOWERS',
        android_channel_id: 'FOLLOWERS',
        priority: 'high',
      }
    };

    try {
      const response = await admin.messaging().send(takipEdilenToken, payload);
      console.log('Bildirim başarıyla gönderildi:', response);
    } catch (error) {
      console.error('Bildirim gönderilirken hata oluştu:', error);
    }
  }
});







/*
exports.logDeleted=functions.firestore.document('deneme/{docId}').onDelete((snapshot,context)=>{
   

   
   admin.firestore().collection("denemecollection").add({
    "description":"Deneme Koleksiyonuna kayıt silindi."
   });

});

exports.logUpdated=functions.firestore.document('deneme/{docId}').onUpdate((change,context)=>{
    

   
   admin.firestore().collection("denemecollection").add({
    "description":"Deneme Koleksiyonuna kayıt güncellendi."
   });

});

exports.writeDone=functions.firestore.document('deneme/{docId}').onWrite((change,context)=>{
    

   
   admin.firestore().collection("denemecollection").add({
    "description":"Deneme Koleksiyonuna veri ekleme,silme,güncelleme işlemlerinden biri gerçekleşti!"
   });

});
*/