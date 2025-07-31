import 'package:flutter/material.dart';

void main() {
  runApp(const StyleSwipeApp());
}

class StyleSwipeApp extends StatelessWidget {
  const StyleSwipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Style Quiz',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const StyleSwipeQuiz(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StyleSwipeQuiz extends StatefulWidget {
  const StyleSwipeQuiz({super.key});

  @override
  State<StyleSwipeQuiz> createState() => _StyleSwipeQuizState();
}

class _StyleSwipeQuizState extends State<StyleSwipeQuiz> {
  // ── 1) assets/images 안의 파일명과 정확히 일치시킬 것 ──
  List<String> styleImages = [
    'assets/images/style1.jpg',
    'assets/images/style2.jpg',
    'assets/images/style3.jpg',
  ];

  // ── 2) 스와이프 결과(1=좋아요, 0=별로) 저장
  final List<int> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('당신의 스타일을 골라보세요'), centerTitle: true),
      body: Center(
        child:
            styleImages.isEmpty
                // 카드가 다 사라지면 결과 보기 버튼
                ? ElevatedButton(
                  child: const Text('결과 보기'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ResultPage(results)),
                    );
                  },
                )
                // 카드 덱: Stack + Dismissible
                : Stack(
                  alignment: Alignment.center,
                  children: List.generate(styleImages.length, (i) {
                    final depth = styleImages.length - i - 1;
                    return Positioned(
                      top: 20.0 + depth * 10,
                      child: Dismissible(
                        key: ValueKey(styleImages[i]),
                        direction: DismissDirection.horizontal,
                        onDismissed: (dir) {
                          // startToEnd=오른쪽, endToStart=왼쪽
                          final liked = dir == DismissDirection.startToEnd;
                          results.add(liked ? 1 : 0);

                          setState(() {
                            styleImages.removeAt(i);
                          });

                          // 자동 결과 페이지 이동
                          if (styleImages.isEmpty) {
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ResultPage(results),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        background: _swipeBg(
                          icon: Icons.thumb_up,
                          alignment: Alignment.centerLeft,
                          color: Colors.green,
                        ),
                        secondaryBackground: _swipeBg(
                          icon: Icons.thumb_down,
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                        ),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              styleImages[i],
                              fit: BoxFit.cover,
                              width: 300,
                              height: 400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
      ),
    );
  }

  Widget _swipeBg({
    required IconData icon,
    required Alignment alignment,
    required Color color,
  }) {
    return Container(
      width: 300,
      height: 400,
      alignment: alignment,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, size: 40, color: Colors.white),
    );
  }
}

class ResultPage extends StatelessWidget {
  final List<int> results;
  const ResultPage(this.results, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('선택 스타일 결과')),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (_, idx) {
          final r = results[idx];
          return ListTile(
            leading: Icon(
              r == 1 ? Icons.thumb_up : Icons.thumb_down,
              color: r == 1 ? Colors.green : Colors.red,
            ),
            title: Text('카드 ${idx + 1}: ${r == 1 ? '좋아요' : '별로'} ($r)'),
          );
        },
      ),
    );
  }
}
