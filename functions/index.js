const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendMoneyReceivedNotification = functions.firestore
  .document('notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const notificationData = snap.data();
    
    // Only process money received notifications
    if (notificationData.type !== 'money_received') {
      return null;
    }

    const { receiverUid, senderName, amount } = notificationData;

    try {
      // Get receiver's FCM token
      const receiverDoc = await admin.firestore()
        .collection('users')
        .doc(receiverUid)
        .get();

      if (!receiverDoc.exists) {
        console.log('Receiver not found:', receiverUid);
        return null;
      }

      const receiverData = receiverDoc.data();
      const fcmToken = receiverData.fcmToken;
      const notificationEnabled = receiverData.notificationEnabled;

      if (!fcmToken || !notificationEnabled) {
        console.log('No FCM token or notifications disabled for user:', receiverUid);
        return null;
      }

      // Prepare notification message
      const message = {
        token: fcmToken,
        notification: {
          title: '💰 Money Received!',
          body: `${senderName} sent you ₹${amount.toFixed(2)}`,
        },
        data: {
          type: 'money_received',
          senderName: senderName,
          amount: amount.toString(),
          receiverUid: receiverUid,
        },
        android: {
          notification: {
            channelId: 'money_received_channel',
            priority: 'high',
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      // Send the notification
      const response = await admin.messaging().send(message);
      console.log('Successfully sent notification:', response);
      
      // Mark notification as sent
      await snap.ref.update({
        sent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      
      // Mark notification as failed
      await snap.ref.update({
        sent: false,
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return null;
    }
  });

// Optional: Clean up old notifications
exports.cleanupOldNotifications = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const snapshot = await admin.firestore()
      .collection('notifications')
      .where('timestamp', '<', thirtyDaysAgo)
      .get();

    const batch = admin.firestore().batch();
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Deleted ${snapshot.docs.length} old notifications`);
  }); 