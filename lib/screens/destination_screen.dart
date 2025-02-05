import 'package:flutter/material.dart';
import '../data/country_data.dart';
import 'chat_room_screen.dart';
import '../services/ad_service.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  String? selectedCountry;

  // 국가와 도시 데이터
  final Map<String, List<String>> countryData = {
    '일본': [
      '도쿄',
      '오사카',
      '후쿠오카',
      '나고야',
      '삿포로',
      '센다이',
      '교토',
      '나라',
      '고베',
      '요코하마',
      '히로시마',
      '가나자와',
      '마쓰야마',
      '오키나와',
      '하코다테'
    ],
    '베트남': [
      '하노이',
      '다낭',
      '호치민',
      '나트랑',
      '푸꾸옥',
      '후에',
      '호이안',
      '달랏',
      '사파',
      '무이네',
      '판티엣',
      '붕따우'
    ],
    '태국': [
      '방콕',
      '치앙마이',
      '푸켓',
      '파타야',
      '후아힌',
      '코사무이',
      '치앙라이',
      '크라비',
      '아유타야',
      '코창'
    ],
    '필리핀': ['마닐라', '세부', '보라카이', '팔라완', '바기오', '클락', '수빅', '엘니도', '코론', '두마게티'],
    '중국': [
      '베이징',
      '상하이',
      '광저우',
      '청두',
      '선전',
      '시안',
      '항저우',
      '칭다오',
      '다렌',
      '충칭',
      '난징',
      '우한',
      '샤먼',
      '구이린'
    ],
    '대만': ['타이페이', '가오슝', '타이중', '타이난', '화련', '지우펀', '예류', '스린', '단수이', '타로코'],
    '싱가포르': ['싱가포르', '센토사 섬', '마리나베이', '오차드로드', '차이나타운', '리틀인디아', '클락키', '부기스'],
    '말레이시아': ['쿠알라룸푸르', '코타키나발루', '페낭', '조호바루', '말라카', '랑카위', '이포', '쿠칭', '미리'],
    '미국': [
      '로스앤젤레스',
      '뉴욕',
      '샌프란시스코',
      '시애틀',
      '라스베가스',
      '시카고',
      '보스턴',
      '마이애미',
      '하와이',
      '워싱턴 D.C.'
    ],
    '호주': ['시드니', '멜버른', '브리즈번', '골드코스트', '케언즈', '퍼스', '애들레이드', '울런공', '다윈'],
    '홍콩': ['센트럴', '침사추이', '몽콕', '카오룽', '란타우', '빅토리아 피크', '홍콩섬', '구룡반도'],
    '마카오': ['마카오반도', '타이파', '코타이', '콜로안'],
    '인도네시아': ['발리', '자카르타', '롬복', '족자카르타', '수라바야', '반둥', '우붓', '기리섬', '코모도'],
    '캄보디아': ['씨엠립', '프놈펜', '시하누크빌', '바탐방'],
    '라오스': ['비엔티안', '루앙프라방', '방비엥', '팍세'],
    '미얀마': ['양곤', '만달레이', '바간', '인레 호수', '네피도'],
    '몽골': ['울란바토르', '테를지', '고비사막', '홉스굴'],
    '인도': ['뉴델리', '뭄바이', '방갈로르', '아그라', '자이푸르', '바라나시', '콜카타', '첸나이', '고아'],
    '네팔': ['카트만두', '포카라', '치트완', '룸비니', '나가르콧'],
    '스리랑카': ['콜롬보', '캔디', '갈레', '누와라엘리야', '시기리야'],
    '영국': [
      '런던',
      '맨체스터',
      '리버풀',
      '에든버러',
      '글래스고',
      '옥스퍼드',
      '케임브리지',
      '브라이튼',
      '바스',
      '요크'
    ],
    '프랑스': [
      '파리',
      '니스',
      '마르세유',
      '리옹',
      '보르도',
      '스트라스부르',
      '몽생미셸',
      '샤모니',
      '칸',
      '아비뇽'
    ],
    '이탈리아': [
      '로마',
      '베네치아',
      '피렌체',
      '밀라노',
      '나폴리',
      '피사',
      '베로나',
      '볼로냐',
      '친퀘테레',
      '시에나',
      '아말피',
      '카프리'
    ],
    '스페인': [
      '마드리드',
      '바르셀로나',
      '세비야',
      '그라나다',
      '발렌시아',
      '톨레도',
      '말라가',
      '산세바스티안',
      '빌바오',
      '이비자'
    ],
    '독일': [
      '베를린',
      '뮌헨',
      '함부르크',
      '프랑크푸르트',
      '쾰른',
      '드레스덴',
      '뉘른베르크',
      '하이델베르크',
      '뒤셀도르프',
      '슈투트가르트'
    ],
    '스위스': ['취리히', '제네바', '루체른', '인터라켄', '베른', '로잔', '체르마트', '몽트뢰', '루가노'],
    '오스트리아': ['빈', '잘츠부르크', '인스브루크', '그라츠', '할슈타트', '린츠'],
    '네덜란드': ['암스테르담', '로테르담', '헤이그', '델프트', '마스트리히트', '위트레흐트', '잔세스칸스'],
    '벨기에': ['브뤼셀', '브뤼헤', '겐트', '안트워프', '뢰벤', '리에주'],
    '포르투갈': ['리스본', '포르투', '신트라', '코임브라', '파로', '마데이라', '오비두스'],
    '그리스': ['아테네', '산토리니', '미코노스', '크레타', '로도스', '델피', '메테오라', '자킨토스', '코르푸'],
    '체코': ['프라하', '체스키크룸로프', '카를로비바리', '브르노', '플젠'],
    '헝가리': ['부다페스트', '에게르', '페치', '데브레첸', '쇼프론'],
    '폴란드': ['바르샤바', '크라쿠프', '그단스크', '브로츠와프', '포즈난', '자코파네'],
    '크로아티아': ['자그레브', '두브로브니크', '스플리트', '플리트비체', '풀라', '자다르'],
    '덴마크': ['코펜하겐', '오덴세', '올보르', '오르후스', '로스킬레'],
    '노르웨이': ['오슬로', '베르겐', '트롬쇠', '스타방에르', '트론헤임', '플롬'],
    '스웨덴': ['스톡홀름', '예테보리', '말뫼', '웁살라', '비스비'],
    '핀란드': ['헬싱키', '투르쿠', '탐페레', '로바니에미', '포르보'],
    '아이슬란드': ['레이캬비크', '비크', '후사비크', '아쿠레이리', '셀포스'],
    '아일랜드': ['더블린', '골웨이', '코크', '킬케니', '리머릭', '클리프오브모허']
  };

  @override
  Widget build(BuildContext context) {
    final sortedCountries = countryData.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '여행지 선택',
          style: TextStyle(color: Color(0xFF4c75e4)),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // 국가 목록 (왼쪽)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white, // 배경색을 흰색으로 변경
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: sortedCountries.length,
                  itemBuilder: (context, index) {
                    String country = sortedCountries[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: selectedCountry == country
                            ? const Color(0xFF4c75e4)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          // 테두리 추가
                          color: selectedCountry == country
                              ? const Color(0xFF4c75e4)
                              : Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          country,
                          style: TextStyle(
                            color: selectedCountry == country
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: selectedCountry == country,
                        onTap: () {
                          setState(() {
                            selectedCountry = country;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            // 도시 목록 (오른쪽)
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                child: selectedCountry == null
                    ? const Center(child: Text('국가를 선택해주세요'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: countryData[selectedCountry]?.length ?? 0,
                        itemBuilder: (context, index) {
                          final sortedCities =
                              countryData[selectedCountry]!.toList()..sort();
                          final city = sortedCities[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                city,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () async {
                                await AdService.showInterstitialAd(); // 광고 표시
                                if (mounted) {
                                  final chatRoomId = '${selectedCountry}_$city'
                                      .replaceAll(' ', '_')
                                      .replaceAll('.', '')
                                      .toLowerCase();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        country: selectedCountry!,
                                        city: city,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
