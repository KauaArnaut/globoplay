import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GloboPlay Desafio',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: SplashScreen(),
    );
  }
}

// Tela de Splash
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MovieListScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'GloboPlay',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}

// Tela de Listagem de Filmes
class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<dynamic> movies = [];
  List<dynamic> favoriteMovies = [];
  List<dynamic> myList = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final apiKey = 'dcf1e7fef6b691ee1e7bf03fd306ffba';
    final url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=pt-BR';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          movies = data['results'];
        });
      } else {
        showError('Erro ao carregar filmes. Tente novamente.');
      }
    } catch (e) {
      showError('Erro de conexão. Verifique sua internet.');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void toggleFavorite(dynamic movie) {
    setState(() {
      if (favoriteMovies.contains(movie)) {
        favoriteMovies.remove(movie);
        myList.remove(movie);
      } else {
        favoriteMovies.add(movie);
        if (!myList.contains(movie)) {
          myList.add(movie);
        }
      }
    });
  }

  
  void removeMovieFromList(dynamic movie) {
    setState(() {
      myList.remove(movie); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          
          Container(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'GloboPlay',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        
          Expanded(
            child: movies.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailScreen(movie: movie),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.black,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                    child: movie['poster_path'] != null
                                        ? Image.network(
                                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                            fit: BoxFit.cover,
                                          )
                                        : Icon(Icons.movie,
                                            size: 100, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['title'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: 'Roboto',
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              favoriteMovies.contains(movie)
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color:
                                                  favoriteMovies.contains(movie)
                                                      ? Colors.yellow
                                                      : Colors.white,
                                            ),
                                            onPressed: () =>
                                                toggleFavorite(movie),
                                          ),
                                          Text(
                                            'Adicionar à Minha Lista',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {
                },
              ),
              Text(
                'Filmes Populares',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.list, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyListScreen(
                        myList: myList,
                        onRemoveMovie: removeMovieFromList,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tela de Detalhes do Filme
class MovieDetailScreen extends StatelessWidget {
  final dynamic movie;

  MovieDetailScreen({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
          title: Text(movie['title'], style: TextStyle(fontFamily: 'Roboto'))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: movie['poster_path'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}'),
                      )
                    : Icon(Icons.movie, size: 100, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                movie['title'],
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                movie['overview'] ?? 'Sem descrição disponível.',
                style: TextStyle(
                    fontSize: 16, fontFamily: 'Roboto', color: Colors.white),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('Assistir', style: TextStyle(fontFamily: 'Roboto')),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.white10, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tela Minha Lista
class MyListScreen extends StatelessWidget {
  final List<dynamic> myList;
  final Function(dynamic) onRemoveMovie;

  MyListScreen({required this.myList, required this.onRemoveMovie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Minha Lista', style: TextStyle(fontFamily: 'Roboto')),
      ),
      body: myList.isEmpty
          ? Center(
              child: Text(
                'Sua lista está vazia.',
                style: TextStyle(
                    fontSize: 16, fontFamily: 'Roboto', color: Colors.white),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: myList.length,
              itemBuilder: (context, index) {
                final movie = myList[index];
                return Card(
                  color: Colors.black,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.list, color: Colors.white),
                    title: Text(
                      movie['title'],
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          color: Colors.white),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.black,
                              title: Text('Remover item',
                                  style: TextStyle(color: Colors.white)),
                              content: Text(
                                'Deseja realmente remover o item da lista?',
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    onRemoveMovie(movie);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Remover',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
