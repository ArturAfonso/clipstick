import 'package:clipstick/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FirstNoteTutorialScreen extends StatefulWidget {
  const FirstNoteTutorialScreen({super.key});

  @override
  State<FirstNoteTutorialScreen> createState() => _FirstNoteTutorialScreenState();
}

class _FirstNoteTutorialScreenState extends State<FirstNoteTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    TutorialPage(
      gifPath: 'assets/reordenar_notas.GIF', 
      title: 'Reordenar Notas',
      description: 'Pressione e arraste uma nota para reordená-la na ordem que desejar.',
    ),
    TutorialPage(
      gifPath: 'assets/setando_marcadores.GIF',
      title: 'Adicionar Marcadores',
      description: 'Ao pressionar por alguns segundos e soltar uma nota, você habilita o modo de seleção e poderá aplicar etiquetas para uma melhor organização. \n(esta aplicação pode ser feita em massa)',
    ),

    TutorialPage(
      gifPath: 'assets/fixnado_notas.GIF',
      title: 'Fixar Notas',
      description: 'Também no modo de seleção você pode fixar notas,que aparecerão no topo. Selecione quantas desejar e toque no ícone de pin para mantê-las sempre a frente das outras.',
    ), 
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishTutorial() {
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6), 
      body: SafeArea(
        child: Column(
          children: [
           
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _finishTutorial,
                  child: Text(
                    'PULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                       
                        Container(
                          height: Get.height * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              page.gifPath,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SizedBox(height: 40),

                        // Título
                        Text(
                          page.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 16),

                   
                        Text(
                          page.description,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

           
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? colorScheme.primary
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

           
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(
                        'Anterior',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 80), 

                 
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Concluir' : 'Próximo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TutorialPage {
  final String gifPath;
  final String title;
  final String description;

  TutorialPage({
    required this.gifPath,
    required this.title,
    required this.description,
  });
}