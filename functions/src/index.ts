import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

// 매일 자정에 실행되는 함수
export const deleteExpiredMessages = functions
  .region("us-central1")  // 리전 변경
  .pubsub
  .schedule("0 0 * * *")
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    // 모든 채팅방을 가져옵니다
    const chatroomsSnapshot = await admin.firestore()
      .collection("chatrooms")
      .get();

    for (const chatroomDoc of chatroomsSnapshot.docs) {
      // 만료된 메시지를 찾아 삭제합니다
      const messagesSnapshot = await chatroomDoc.ref
        .collection("messages")
        .where("expiresAt", "<=", now)
        .get();

      const batch = admin.firestore().batch();
      const storage = admin.storage();
      
      // 이미지 URL 목록을 수집합니다
      const imageUrls: string[] = [];
      
      messagesSnapshot.docs.forEach((doc) => {
        const data = doc.data();
        if (data.type === "image" && data.imageUrl) {
          imageUrls.push(data.imageUrl);
        }
        batch.delete(doc.ref);
      });

      if (messagesSnapshot.docs.length > 0) {
        // Firestore 메시지 삭제
        await batch.commit();
        
        // Storage 이미지 파일 삭제
        for (const imageUrl of imageUrls) {
          try {
            // imageUrl에서 파일 경로 추출
            const filePathMatch = imageUrl.match(/chat_images%2F(.+)\?/);
            if (filePathMatch) {
              const filePath = `chat_images/${filePathMatch[1]}`;
              const fileRef = storage.bucket().file(filePath);
              await fileRef.delete();
            }
          } catch (error) {
            console.error("Error deleting image:", error);
          }
        }

        console.log(
          `Deleted ${messagesSnapshot.docs.length} expired messages ` +
          `and ${imageUrls.length} images from ` +
          `chatroom ${chatroomDoc.id}`
        );
      }
    }
    
    return null;
  });