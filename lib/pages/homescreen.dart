import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled7/cubit/news_cubit.dart';
import 'package:untitled7/pages/detailed_view.dart';
import 'package:untitled7/pages/settings.dart';
import '../data/news_api_service.dart';
import 'cust_widget/cust_news.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    getUser();
    wishes();
    super.initState();
  }
  var name;
  getUser()async{
    SharedPreferences user=await SharedPreferences.getInstance();
       setState(() {
         name=user.getString("name")?.toUpperCase();
       });
     print(name);
  }
  var greeting;
  wishes(){
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    print(greeting);
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
  create: (context) => NewsCubit(
    newsApiService:NewsApiService.create()
  )..fetch(),
  child: Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(double.infinity, 130),
        child: AppBar(
          centerTitle: true,
          title: const Text(
            "News.live",
            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
              gradient: LinearGradient(colors: [Colors.red, Colors.orange]),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$greeting, $name", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text(
                      "99c",
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(5)),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.pushNamed(context, "/settings");
                    },
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 30),
          BlocBuilder<NewsCubit,NewsState>(
            // bloc: NewsCubit..fetch,
            builder: (context, state) {
              return state.when(
                initial: () => const SizedBox(),
                loading: () => const Center(child: CircularProgressIndicator()),
                loaded: (newsList) => Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Details(title:newsList.articles[index].title.toString(),image: newsList.articles[index].urlToImage.toString(),description: newsList.articles[index].description.toString(),author:newsList.articles[index].author.toString() ,content: newsList.articles[index].content.toString(),publishedAt: newsList.articles[index].publishedAt.toString(),url: newsList.articles[index].url.toString(),),));
                        },
                        child: cust_news(
                          heading: newsList.articles[index].title.toString(),
                          description: newsList.articles[index].author.toString()
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                    itemCount: newsList.articles.length,
                  ),
                ), Error: ()=>const Center(child: Text("error"),)
              );
            },
          )
        ],
      ),
    ),
);
  }
}
