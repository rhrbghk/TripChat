import 'package:flutter/material.dart';
import '../data/country_data.dart';
import 'chat_room_screen.dart';
import 'chat_rooms_screen.dart';
import '../services/ad_service.dart';

class AllChatRoomsScreen extends StatefulWidget {
  const AllChatRoomsScreen({super.key});

  @override
  State<AllChatRoomsScreen> createState() => _AllChatRoomsScreenState();
}

class _AllChatRoomsScreenState extends State<AllChatRoomsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MapEntry<String, String>> _allCities = [];
  List<MapEntry<String, String>> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _allCities = getAllCityRooms();
    _filteredCities = _allCities;
  }

  List<MapEntry<String, String>> getAllCityRooms() {
    List<MapEntry<String, String>> allCities = [];

    CountryData.data.forEach((country, cities) {
      for (var city in cities) {
        allCities.add(MapEntry(country, city));
      }
    });

    allCities.sort((a, b) => a.value.compareTo(b.value));
    return allCities;
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _allCities;
      } else {
        _filteredCities = _allCities.where((city) {
          final cityName = city.value.toLowerCase();
          final countryName = city.key.toLowerCase();
          final searchLower = query.toLowerCase();
          return cityName.contains(searchLower) ||
              countryName.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '전체 채팅방',
          style: TextStyle(color: Color(0xFF4c75e4)),
        ),
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '도시 또는 국가 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterCities('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterCities,
            ),
          ),
          // 검색 결과 카운트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '검색 결과: ${_filteredCities.length}개',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // 채팅방 목록
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                return ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: Text(city.value), // 도시 이름
                  subtitle: Text(city.key), // 국가 이름
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await AdService.showInterstitialAd(); // 광고 표시
                    if (mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            country: city.key,
                            city: city.value,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
