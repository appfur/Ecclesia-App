import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedBookText() async {
  final firestore = FirebaseFirestore.instance;

  final booksQuery = await firestore.collectionGroup('books').get();

  final List<String> images = [
    "https://th.bing.com/th/id/OIP.2th0-WS12c_oOdtSzrHR3QHaGS?r=0&rs=1&pid=ImgDetMain",
    "https://images-platform.99static.com/RHiIaEEqKAOVs9D5fF70AAgC8tc=/402x190:1446x1234/fit-in/500x500/projects-files/186/18640/1864025/3bb3533b-e169-472f-b854-3a28651993b6.jpg",
    "https://th.bing.com/th/id/OIP.FHtlRAywu7C88tG80EMviAHaFk?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3",
    "https://th.bing.com/th/id/R.921dd34067495abf3e4dc4e22af142a7?rik=o1VqQ6Dgj%2bPzKg&riu=http%3a%2f%2f1.bp.blogspot.com%2f-eCc0nYjfyY4%2fT3U3MoglmGI%2fAAAAAAAAAV4%2fFAQUxoFgJ8s%2fs1600%2fBible.jpg&ehk=V3hrIkoHFP5dMeprkmNjXHiqk5dxky1UEmDYo9pTs%2fg%3d&risl=&pid=ImgRaw&r=0",
  ];

  final List<String> fullLengthDevotionals = [
    "There are seasons in life where everything feels like it's falling apart — doors close, opportunities vanish, and silence stretches for days. In such times, it’s easy to believe God has gone quiet, but those are often the moments He is the most present. Like a gardener pruning a tree, God removes what is unnecessary so that we can grow stronger in faith, deeper in character, and more fruitful in purpose. Even when we don’t understand, He is working. The pain you feel may not be punishment, but preparation. Remember Joseph — sold into slavery, imprisoned without cause, yet through it all, God was orchestrating a purpose greater than Joseph could imagine. God does the same with you. He sees the end from the beginning, and no suffering is wasted. The storms you face today are shaping the testimony you’ll carry tomorrow. Trust the process. Rest in the truth that the same God who created galaxies and split seas knows your name, your story, and your tomorrow.",

    "Faith isn't a feeling; it's a decision to trust God even when the road is dark, and the answers are unclear. It's waking up every day and saying, 'God, I don't see the way, but I trust You are leading me.' Faith is Abraham walking toward a mountain not knowing that God had already provided a ram. Faith is Daniel kneeling in prayer even when lions waited below. Faith is Mary saying, 'Let it be unto me' though she could be stoned. Your faith may feel small, but small faith in a big God is powerful. Don’t compare your faith walk to others. God doesn’t call you to perfect faith — He calls you to persistent faith. Keep pressing in. Keep standing. And know this: your faith will not be wasted. In due season, the harvest will come.",

    "There is power in surrender. We often think control keeps us safe, but true peace is found in letting go. Jesus didn't cling to status or power. He humbled Himself. He served. He sacrificed. And in that surrender, He changed the world. When we release our grip on outcomes and plans, we give space for God to move freely in our lives. That relationship you’re holding too tightly? That dream that hasn’t happened yet? Lay them down. Surrender isn’t weakness. It’s wisdom. It’s choosing to trust God’s ways over our own. And when we do, we discover a peace that surpasses understanding. Not because everything is perfect, but because we’ve placed our trust in the One who is.",

    "The Word of God is not just a book — it’s alive. It speaks into situations, convicts hearts, breaks chains, and builds faith. Every page is a promise. Every verse a weapon. In seasons of anxiety, it calms the storm within. In seasons of doubt, it reminds you who you are and whose you are. But the Word cannot work if it’s closed. Open it. Meditate on it. Let it dwell in your heart richly. You don’t need to understand everything at once — just read, and the Spirit will bring it to life. Over time, you’ll find that the scriptures are not just about ancient people; they are about you. Your story. Your fight. Your promise. So carry the Word with you. Let it be your sword and shield.",

    "You are loved — not for what you do, but for who you are. Before you ever served, preached, gave, or sang — God loved you. Before you overcame that addiction or cleaned up your life — God loved you. His love is not based on your perfection but on His. The enemy wants you to believe that your flaws disqualify you, but God specializes in using broken people. David was an adulterer. Paul was a persecutor. Peter denied Jesus. And yet they were all used mightily. You are not too far gone. You are not forgotten. Grace is not just enough — it’s overflowing. Receive it today. Walk in the confidence that you are His beloved.",

    "Heaven is not just a destination — it's a perspective. When you fix your eyes on eternity, your current struggles shrink in comparison. Pain has purpose. Trials produce endurance. And through every storm, Jesus is forming in you a faith that cannot be shaken. This world is not our home. The job, the fame, the status — it all fades. But what you do for Christ lasts forever. Live today with eternity in mind. Love radically. Forgive freely. Give generously. Speak truth boldly. Your reward is not in the applause of men but in the eyes of the One who sees in secret.",

    "Prayer is not a ritual — it's a relationship. It’s the oxygen of your spirit. You don’t have to have fancy words. Just be honest. Come as you are. God would rather hear your messy truth than your fake praise. He already knows your heart, so just speak. And more importantly, listen. Prayer is not just about talking — it’s about quieting your soul to hear His whisper. You might not hear an audible voice, but you’ll sense a peace, a direction, a nudge. That’s Him. He’s closer than you think.",

    "Your identity is not in your failure, your past, or your pain. It is in Christ. You are a child of God, a royal priesthood, a chosen generation. When the enemy reminds you of who you were, remind him of who you are. Speak the Word over yourself. Declare God’s promises. You are the head and not the tail. Above only, never beneath. You are loved, seen, chosen, and called. No weapon formed against you shall prosper. This isn’t hype — it’s the truth. Walk in it.",

    "Obedience isn’t always easy, but it’s always worth it. Noah obeyed before the rain. Abraham obeyed without knowing the destination. Jesus obeyed unto death. Obedience may cost you comfort, friends, or opportunities, but it will never cost you God's presence. Delayed obedience is disobedience. So when God speaks, respond. Trust that He sees what you can’t. Every step of obedience builds something eternal.",

    "Peace is not found in a place — it’s found in a Person. Jesus said, 'My peace I give to you, not as the world gives.' The world’s peace is fragile — based on circumstances. But God’s peace is steady in chaos. It guards your heart when the bills stack up, when the report is bad, when the future is unclear. That peace isn’t denial — it’s divine. Receive it. Rest in it. Let it carry you through the storm.",
  ];

  for (final bookDoc in booksQuery.docs) {
    final bookRef = bookDoc.reference;
    final bookData = bookDoc.data();
    final bookTitle = bookData['title'] ?? 'Untitled';
    final bookCover = bookData['cover_image'];

    print('📘 Seeding full-screen content for: $bookTitle');

    // Seed metadata
    final metadataRef = bookRef.collection('metadata').doc('stats');
    await metadataRef.set({
      'likes': 0,
      'love': 0,
      'rating': 0.0,
      'rating_count': 0,
    });

    // Seed chapters
    for (int chapterIndex = 0; chapterIndex < 3; chapterIndex++) {
      final chapterImage =
          (chapterIndex % 2 == 0)
              ? images[chapterIndex % images.length]
              : bookCover;

      final chapterDoc = await bookRef.collection('chapters').add({
        'title': 'Chapter ${chapterIndex + 1}',
        'order': chapterIndex + 1,
        'image_url': chapterImage,
      });

      // Seed 5 full-screen devotional paragraphs per chapter
      for (int pageIndex = 0; pageIndex < 5; pageIndex++) {
        final index =
            (chapterIndex * 5 + pageIndex) % fullLengthDevotionals.length;
        final content = fullLengthDevotionals[index];

        await chapterDoc.collection('pages').add({
          'page_number': pageIndex + 1,
          'content': content,
        });
      }
    }
  }

  print("✅ Long-form devotional paragraphs seeded into book pages.");
}
