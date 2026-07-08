import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app_language.dart';
import 'team_onboarding_screen.dart';

class ChallengeItem {
  final String id;
  final String titleEn;
  final String titleKo;
  final String titleJa;
  final String titleEs;
  final String titleZh;
  final String descEn;
  final String descKo;
  final String descJa;
  final String descEs;
  final String descZh;
  final String goalEn;
  final String goalKo;
  final String goalJa;
  final String goalEs;
  final String goalZh;
  final String rewardEn;
  final String rewardKo;
  final String rewardJa;
  final String rewardEs;
  final String rewardZh;
  double progress;
  double current;
  final double total;
  final int daysLeft;
  final Color color;

  ChallengeItem({
    required this.id,
    required this.titleEn,
    required this.titleKo,
    required this.titleJa,
    required this.titleEs,
    required this.titleZh,
    required this.descEn,
    required this.descKo,
    required this.descJa,
    required this.descEs,
    required this.descZh,
    required this.goalEn,
    required this.goalKo,
    required this.goalJa,
    required this.goalEs,
    required this.goalZh,
    required this.rewardEn,
    required this.rewardKo,
    required this.rewardJa,
    required this.rewardEs,
    required this.rewardZh,
    this.progress = 0.0,
    this.current = 0.0,
    required this.total,
    required this.daysLeft,
    required this.color,
  });

  String get title => AppLanguage.t(
    en: titleEn,
    ko: titleKo,
    ja: titleJa,
    es: titleEs,
    zh: titleZh,
  );
  String get description =>
      AppLanguage.t(en: descEn, ko: descKo, ja: descJa, es: descEs, zh: descZh);
  String get goal =>
      AppLanguage.t(en: goalEn, ko: goalKo, ja: goalJa, es: goalEs, zh: goalZh);
  String get reward => AppLanguage.t(
    en: rewardEn,
    ko: rewardKo,
    ja: rewardJa,
    es: rewardEs,
    zh: rewardZh,
  );

  String get totalString =>
      total.toInt() == total ? '${total.toInt()} ' : '$total ';
  String get currentString =>
      current.toInt() == current ? '${current.toInt()}' : '$current';
}

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late ConfettiController _confettiController;

  final List<ChallengeItem> _allChallenges = [
    ChallengeItem(
      id: '1',
      titleEn: 'Beat the Heat Challenge',
      titleKo: '폭염 이겨내기 챌린지',
      titleJa: '猛暑を乗り越えるチャレンジ',
      titleEs: 'Desafío Vencer el Calor',
      titleZh: '战胜酷暑挑战',
      goalEn: 'Run 30km in 2 weeks',
      goalKo: '2주간 30km 달리기',
      goalJa: '2週間で30km走る',
      goalEs: 'Correr 30km en 2 semanas',
      goalZh: '2周内跑30公里',
      descEn:
          'Don\'t give up to the heat and keep running. Build a summer exercise habit and donations accumulate.',
      descKo: '더위에 지지 않고 꾸준히 달려보자.',
      descJa: '暑さに負けず走り続けよう。',
      descEs: 'No te rindas al calor y sigue corriendo.',
      descZh: '不要被炎热打倒，坚持跑步。',
      rewardEn: '+300won extra donation & Heat Conqueror badge',
      rewardKo: '+300원 추가 기부 및 폭염 극복 뱃지',
      rewardJa: '+300ウォン追加寄付＆猛暑克服バッジ',
      rewardEs: '+300won donación extra y badge Conquistador del Calor',
      rewardZh: '+300韩元额外捐款及战胜酷暑徽章',
      total: 30.0,
      daysLeft: 14,
      color: const Color(0xFFFF6B6B),
    ),
    ChallengeItem(
      id: '2',
      titleEn: 'Sunset Running Challenge',
      titleKo: '선셋 러닝 챌린지',
      titleJa: 'サンセットランニングチャレンジ',
      titleEs: 'Desafío Running al Atardecer',
      titleZh: '日落跑步挑战',
      goalEn: 'Certify 5 sunset runs',
      goalKo: '일몰 시간대 러닝 5회 인증',
      goalJa: '日没時間帯のランニング5回認証',
      goalEs: 'Certificar 5 carreras al atardecer',
      goalZh: '认证5次日落跑步',
      descEn:
          'The most beautiful running time. Enjoy summer evenings running under the crimson sky.',
      descKo: '가장 아름다운 러닝 타임. 붉게 물든 하늘 아래 달리며 여름 저녁을 즐겨보자.',
      descJa: '最も美しいランニングタイム。夕焼け空の下で走り夏の夕べを楽しもう。',
      descEs:
          'El tiempo de carrera más hermoso. Disfruta las tardes de verano corriendo bajo el cielo rojizo.',
      descZh: '最美丽的跑步时光。在红色的天空下奔跑，享受夏天的傍晚。',
      rewardEn: '+150won extra donation & Sunset Runner badge',
      rewardKo: '+150원 추가 기부 및 노을 러너 뱃지',
      rewardJa: '+150ウォン追加寄付＆夕焼けランナーバッジ',
      rewardEs: '+150won donación extra y badge Corredor del Atardecer',
      rewardZh: '+150韩元额外捐款及日落跑者徽章',
      total: 5.0,
      daysLeft: 14,
      color: const Color(0xFFFF8E53),
    ),
    ChallengeItem(
      id: '3',
      titleEn: 'Miracle Morning Challenge',
      titleKo: '미라클 챌린지',
      titleJa: 'ミラクルチャレンジ',
      titleEs: 'Desafío Mañana Milagro',
      titleZh: '奇迹早晨挑战',
      goalEn: 'Run 7 times before 7AM',
      goalKo: '오전 7시 이전 러닝 7회 달성',
      goalJa: '午前7時前のランニング7回達成',
      goalEs: 'Correr 7 veces antes de las 7AM',
      goalZh: '7点前完成7次跑步',
      descEn:
          'A challenge for those who start the day before others. Create a productive day with morning running.',
      descKo: '하루를 남들보다 먼저 시작하는 사람들의 챌린지.',
      descJa: '誰よりも早く一日を始める人のチャレンジ。',
      descEs: 'Un desafío para quienes comienzan el día antes que los demás.',
      descZh: '比别人更早开始一天的人的挑战。',
      rewardEn: '+200won extra donation & Miracle Morning badge',
      rewardKo: '+200원 추가 기부 및 미라클 모닝 뱃지',
      rewardJa: '+200ウォン追加寄付＆ミラクルモーニングバッジ',
      rewardEs: '+200won donación extra y badge Mañana Milagro',
      rewardZh: '+200韩元额外捐款及奇迹早晨徽章',
      total: 7.0,
      daysLeft: 7,
      color: const Color(0xFFFEE140),
    ),
    ChallengeItem(
      id: '4',
      titleEn: 'God Life Challenge',
      titleKo: 'GOD생 챌린지',
      titleJa: 'GOD生チャレンジ',
      titleEs: 'Desafío Vida Perfecta',
      titleZh: '完美生活挑战',
      goalEn: '7 days consecutive running & 10km total',
      goalKo: '7일 연속 러닝 및 누적 10km',
      goalJa: '7日連続ランニング＆累計10km',
      goalEs: '7 días consecutivos corriendo y 10km acumulados',
      goalZh: '连续7天跑步并累计10公里',
      descEn:
          'No more giving up after 3 days. Build a healthy routine by running consistently for a week.',
      descKo: '작심삼일은 끝. 일주일 동안 꾸준히 달리며 건강한 루틴을 만들어보자.',
      descJa: '三日坊主は終わり。1週間コツコツ走り健康なルーティンを作ろう。',
      descEs:
          'Se acabó rendirse al tercer día. Crea una rutina saludable corriendo durante una semana.',
      descZh: '不再三天打鱼两天晒网。通过坚持一周跑步来建立健康的日常习惯。',
      rewardEn: '+250won extra donation & God Lifer badge',
      rewardKo: '+250원 추가 기부 및 갓생러 뱃지',
      rewardJa: '+250ウォン追加寄付＆GOD生バッジ',
      rewardEs: '+250won donación extra y badge Vida Perfecta',
      rewardZh: '+250韩元额외捐款及完美生活者徽章',
      total: 10.0,
      daysLeft: 7,
      color: const Color(0xFF00C896),
    ),
    ChallengeItem(
      id: '5',
      titleEn: 'Watermelon Challenge',
      titleKo: '수박 한 통 챌린지',
      titleJa: 'スイカ一玉チャレンジ',
      titleEs: 'Desafío Sandía Entera',
      titleZh: '整个西瓜挑战',
      goalEn: 'Achieve 20km total',
      goalKo: '누적 20km 달성',
      goalJa: '累計20km達成',
      goalEs: 'Lograr 20km en total',
      goalZh: '累计完成20公里',
      descEn:
          'Burn the calories of a whole watermelon. Feel the cool sense of achievement.',
      descKo: '여름 대표 과일 수박 한 통 칼로리를 태운다는 컨셉.',
      descJa: '夏の代表フルーツ、スイカ一玉分のカロリーを燃やすコンセプト。',
      descEs:
          'Quema las calorías de una sandía entera. Siente esa fresca sensación de logro.',
      descZh: '燃烧掉整个西瓜的卡路里。感受清凉的成就感。',
      rewardEn: '+200won extra donation & Watermelon badge',
      rewardKo: '+200원 추가 기부 및 수박 뱃지',
      rewardJa: '+200ウォン追加寄付＆スイカバッジ',
      rewardEs: '+200won donación extra y badge Sandía',
      rewardZh: '+200韩元额外捐款及西瓜徽章',
      total: 20.0,
      daysLeft: 14,
      color: const Color(0xFF4E9F3D),
    ),
    ChallengeItem(
      id: '6',
      titleEn: 'AC Off Challenge',
      titleKo: '에어컨 off 챌린지',
      titleJa: 'エアコンオフチャレンジ',
      titleEs: 'Desafío AC Apagado',
      titleZh: '关空调挑战',
      goalEn: 'Turn off AC and plogging for 1 hour a day',
      goalKo: '하루 1시간 에어컨 끄고 플로깅',
      goalJa: '1日1時間エアコンを切ってプロギング',
      goalEs: 'Apagar el AC y hacer plogging 1 hora al día',
      goalZh: '每天关空调1小时并捡垃圾跑步',
      descEn:
          'Cool down the earth! Turn off the AC and do light plogging around the neighborhood.',
      descKo: '지구를 시원하게! 에어컨을 잠시 끄고 동네를 가볍게 달리며 쓰레기를 줍는 환경 보호 챌린지.',
      descJa: '地球を涼しく！エアコンを少し切って町を軽く走りながらゴミを拾う環境保護チャレンジ。',
      descEs:
          '¡Enfría la tierra! Apaga el AC y haz plogging ligero por el vecindario.',
      descZh: '让地球凉爽！关掉空调，在社区轻松跑步同时捡垃圾的环保挑战。',
      rewardEn: '+300won extra donation & Eco Runner badge',
      rewardKo: '+300원 추가 기부 및 에코 러너 뱃지',
      rewardJa: '+300ウォン追加寄付＆エコランナーバッジ',
      rewardEs: '+300won donación extra y badge Corredor Eco',
      rewardZh: '+300韩元额外捐款及环保跑者徽章',
      total: 7.0,
      daysLeft: 7,
      color: const Color(0xFF00D2FC),
    ),
    ChallengeItem(
      id: '7',
      titleEn: 'Pre-Beach Challenge',
      titleKo: '바다 가기 전 챌린지',
      titleJa: '海に行く前チャレンジ',
      titleEs: 'Desafío Antes de la Playa',
      titleZh: '去海边前挑战',
      goalEn: 'Achieve 30km total',
      goalKo: '누적 30km 달성하기',
      goalJa: '累計30km達成',
      goalEs: 'Lograr 30km en total',
      goalZh: '累计完成30公里',
      descEn: 'Build solid stamina before your summer vacation at the beach.',
      descKo: '여름 휴가, 바다로 떠나기 전 탄탄한 기초 체력을 다져보는 본격 러닝 프로젝트.',
      descJa: '夏休みに海へ出発する前に、しっかりとした基礎体力をつける本格ランニングプロジェクト。',
      descEs:
          'Construye una sólida resistencia antes de tu vacación de verano en la playa.',
      descZh: '在暑假去海边之前建立扎实的基础体力。',
      rewardEn: '+500won extra donation & Ocean Challenger badge',
      rewardKo: '+500원 추가 기부 및 오션 챌린저 뱃지',
      rewardJa: '+500ウォン追加寄付＆オーシャンチャレンジャーバッジ',
      rewardEs: '+500won donación extra y badge Desafiante del Océano',
      rewardZh: '+500韩元额外捐款及海洋挑战者徽章',
      total: 30.0,
      daysLeft: 14,
      color: const Color(0xFFFF416C),
    ),
    ChallengeItem(
      id: '8',
      titleEn: 'Sunscreen Runner Challenge',
      titleKo: '썬크림 러너 챌린지',
      titleJa: '日焼け止めランナーチャレンジ',
      titleEs: 'Desafío Corredor con Protector Solar',
      titleZh: '防晒跑者挑战',
      goalEn: 'Certify 3 daytime runs',
      goalKo: '낮 시간대 러닝 3회 인증',
      goalJa: '昼間のランニング3回認証',
      goalEs: 'Certificar 3 carreras diurnas',
      goalZh: '认证3次白天跑步',
      descEn:
          'Nothing can stop you, not even the hot sun! Put on sunscreen and face the energy of summer.',
      descKo: '뜨거운 태양도 막을 수 없다! 자외선 차단제 단단히 바르고 여름의 에너지를 마주하는 도전.',
      descJa: '熱い太陽も止められない！日焼け止めをしっかり塗って夏のエネルギーに立ち向かうチャレンジ。',
      descEs:
          '¡Nada puede detenerte, ni siquiera el sol! Ponte protector solar y enfrenta la energía del verano.',
      descZh: '没有什么能阻止你，就算是烈日也不行！涂上防晒霜，面对夏日的能量。',
      rewardEn: '+200won extra donation & Sun Proof badge',
      rewardKo: '+200원 추가 기부 및 태양을 피하는 방법 뱃지',
      rewardJa: '+200ウォン追加寄付＆サンプルーフバッジ',
      rewardEs: '+200won donación extra y badge A Prueba de Sol',
      rewardZh: '+200韩元额外捐款及防晒徽章',
      total: 3.0,
      daysLeft: 10,
      color: const Color(0xFFFFB300),
    ),
    ChallengeItem(
      id: '9',
      titleEn: 'Tropical Night Escape',
      titleKo: '열대야 탈출 챌린지',
      titleJa: '熱帯夜脱出チャレンジ',
      titleEs: 'Desafío Escape de Noche Tropical',
      titleZh: '热带夜逃脱挑战',
      goalEn: 'Certify 5 night runs after 9PM',
      goalKo: '밤 9시 이후 야간 러닝 5회 인증',
      goalJa: '夜9時以降の夜間ランニング5回認証',
      goalEs: 'Certificar 5 carreras nocturnas después de las 9PM',
      goalZh: '认证5次晚上9点后的夜跑',
      descEn:
          'On sleepless summer nights, blow away the stress of the day with a cool night breeze city run.',
      descKo: '잠 못 드는 여름 밤, 시원한 밤바람을 맞으며 하루의 스트레스를 날려버리는 야간 시티런.',
      descJa: '眠れない夏の夜、涼しい夜風を受けながら一日のストレスを吹き飛ばす夜間シティラン。',
      descEs:
          'En las noches de verano en que no puedes dormir, elimina el estrés del día con una carrera nocturna.',
      descZh: '在难以入眠的夏夜，迎着凉爽的夜风吹走一天的压力，享受夜间城市跑。',
      rewardEn: '+250won extra donation & Midnight Runner badge',
      rewardKo: '+250원 추가 기부 및 미드나잇 러너 뱃지',
      rewardJa: '+250ウォン追加寄付＆ミッドナイトランナーバッジ',
      rewardEs: '+250won donación extra y badge Corredor de Medianoche',
      rewardZh: '+250韩元额外捐款及午夜跑者徽章',
      total: 5.0,
      daysLeft: 14,
      color: const Color(0xFF8A2387),
    ),
    ChallengeItem(
      id: '10',
      titleEn: 'Donation Marathon Challenge',
      titleKo: '기부 마라톤 챌린지',
      titleJa: '寄付マラソンチャレンジ',
      titleEs: 'Desafío Maratón de Donación',
      titleZh: '捐款马拉松挑战',
      goalEn: 'Achieve 42.195km in 2 weeks',
      goalKo: '2주간 누적 42.195km 달성',
      goalJa: '2週間で累計42.195km達成',
      goalEs: 'Lograr 42.195km en 2 semanas',
      goalZh: '2周内累计跑42.195公里',
      descEn:
          'A challenge that transcends the limits of summer! Complete the full marathon distance and send warmth to those in need.',
      descKo: '여름의 한계를 뛰어넘는 도전!',
      descJa: '夏の限界を超えるチャレンジ！',
      descEs: '¡Un desafío que trasciende los límites del verano!',
      descZh: '超越夏日极限的挑战！',
      rewardEn: '+1000won extra donation & Summer Marathoner badge',
      rewardKo: '+1000원 추가 기부 및 여름 마라토너 뱃지',
      rewardJa: '+1000ウォン追加寄付＆夏のマラソナーバッジ',
      rewardEs: '+1000won donación extra y badge Maratonista de Verano',
      rewardZh: '+1000韩元额外捐款及夏日马拉松手徽章',
      total: 42.195,
      daysLeft: 14,
      color: const Color(0xFF11998E),
    ),
    ChallengeItem(
      id: '11',
      titleEn: '7979 Friend Challenge',
      titleKo: '7979 친구 챌린지',
      titleJa: '7979フレンドチャレンジ',
      titleEs: 'Desafío Amigo 7979',
      titleZh: '7979好友挑战',
      goalEn: 'Achieve 79.79km combined with a friend',
      goalKo: '친구와 합산 79.79km 달성',
      goalJa: '友達と合計79.79km達成',
      goalEs: 'Lograr 79.79km combinados con un amigo',
      goalZh: '与好友合计完成79.79公里',
      descEn:
          'Run with a friend. Together you can go further than alone. Achieve 79.79km with your friend and get rewarded together.',
      descKo: '친구와 함께 달리자. 혼자보단 둘이 함께 달리면 더 멀리 갈 수 있다.',
      descJa: '友達と一緒に走ろう。一人より二人で走る方がもっと遠くへ行ける。',
      descEs: 'Corre con un amigo. Juntos pueden ir más lejos que solos.',
      descZh: '和朋友一起跑。两个人比一个人跑得更远。',
      rewardEn: '+500won extra donation & Friendship Runner badge',
      rewardKo: '+500원 추가 기부 및 우정 러너 뱃지',
      rewardJa: '+500ウォン追加寄付＆フレンドシップランナーバッジ',
      rewardEs: '+500won donación extra y badge Corredor de la Amistad',
      rewardZh: '+500韩元额外捐款及友谊跑者徽章',
      total: 79.79,
      daysLeft: 30,
      color: const Color(0xFF7C3AED),
    ),
    ChallengeItem(
      id: '12',
      titleEn: 'Team Spirit Challenge',
      titleKo: '고통도 친구와 나누면 쉽다',
      titleJa: 'チームスピリットチャレンジ',
      titleEs: 'Desafío Espíritu de Equipo',
      titleZh: '团队精神挑战',
      goalEn: 'Run 50km as a team',
      goalKo: '팀원과 합산 50km 달성',
      goalJa: 'チームで合計50km走る',
      goalEs: 'Correr 50km como equipo',
      goalZh: '团队合计跑50公里',
      descEn:
          'Pain shared is pain halved. Run together with your team and make every step count!',
      descKo: '고통도 친구와 나누면 쉽다. 팀원과 함께 달리며 모든 발걸음을 의미있게 만들어보자!',
      descJa: '苦しみも友と分かち合えば楽になる。チームと一緒に走ろう！',
      descEs:
          'El dolor compartido es menos. ¡Corre con tu equipo y haz que cada paso cuente!',
      descZh: '与朋友分担痛苦，痛苦减半。和团队一起跑步，让每一步都有意义！',
      rewardEn:
          '+500won extra donation & Team Runner badge + ×1.5 donation multiplier!',
      rewardKo: '+500원 추가 기부 및 팀 러너 뱃지 + 기부금 1.5배!',
      rewardJa: '+500ウォン追加寄付＆チームランナーバッジ＋寄付1.5倍！',
      rewardEs:
          '+500won donación extra y badge Team Runner + ¡×1.5 multiplicador!',
      rewardZh: '+500韩元额外捐款及团队跑者徽章+捐款1.5倍！',
      total: 50.0,
      daysLeft: 14,
      color: const Color(0xFF00C896),
    ),
    ChallengeItem(
      id: '13',
      titleEn: 'Together We Run Further',
      titleKo: '혼자보다 함께가 더 멀리',
      titleJa: '一人より仲間と走れば遠くへ行ける',
      titleEs: 'Juntos Llegamos Más Lejos',
      titleZh: '一起跑得更远',
      goalEn: 'All team members run at least 5km each',
      goalKo: '팀원 전원이 각자 5km 이상 달성',
      goalJa: 'チーム全員が各自5km以上達成',
      goalEs: 'Todos los miembros del equipo corren al menos 5km',
      goalZh: '所有团队成员各自跑5公里以上',
      descEn:
          'No one gets left behind. Every team member must run at least 5km. Support each other!',
      descKo: '아무도 뒤처지지 않는다. 팀원 모두가 5km 이상 달려야 해요. 서로를 응원하세요!',
      descJa: '誰一人取り残さない。チーム全員が5km以上走ろう。お互いを応援しよう！',
      descEs:
          'Nadie se queda atrás. Todos deben correr al menos 5km. ¡Apóyense mutuamente!',
      descZh: '不让任何人掉队。每个团队成员都必须跑5公里以上。互相加油！',
      rewardEn:
          '+300won extra donation & Unity badge + ×1.5 donation multiplier!',
      rewardKo: '+300원 추가 기부 및 유니티 뱃지 + 기부금 1.5배!',
      rewardJa: '+300ウォン追加寄付＆ユニティバッジ＋寄付1.5倍！',
      rewardEs: '+300won donación extra y badge Unidad + ¡×1.5 multiplicador!',
      rewardZh: '+300韩元额外捐款及团结徽章+捐款1.5倍！',
      total: 5.0,
      daysLeft: 7,
      color: const Color(0xFF7C3AED),
    ),
  ];

  final Set<String> _joinedIds = {};
  final List<String> _completedChallenges = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _show(ChallengeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final has = _joinedIds.contains(item.id);
                final isFull = _joinedIds.length >= 3;
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2535),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${AppLanguage.t(en: 'Goal', ko: '목표', ja: '目標', es: 'Meta', zh: '目标')}: ${item.goal}',
                            style: TextStyle(
                              color: item.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLanguage.t(
                            en: 'Description',
                            ko: '챌린지 설명',
                            ja: 'チャレンジ説明',
                            es: 'Descripción',
                            zh: '挑战说明',
                          ),
                          style: const TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.description,
                          style: const TextStyle(
                            color: Color(0xFFE5E7EB),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLanguage.t(
                            en: 'Reward',
                            ko: '달성 보상',
                            ja: '達成報酬',
                            es: 'Recompensa',
                            zh: '奖励',
                          ),
                          style: const TextStyle(
                            color: Color(0xFF8899AA),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.reward,
                          style: const TextStyle(
                            color: Color(0xFF00C896),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!has && isFull)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Center(
                              child: Text(
                                AppLanguage.t(
                                  en: 'You can only join up to 3 challenges at once.',
                                  ko: '챌린지는 동시에 최대 3개까지만 도전할 수 있습니다.',
                                  ja: 'チャレンジは同時に最大3つまで挑戦できます。',
                                  es: 'Solo puedes unirte a un máximo de 3 desafíos a la vez.',
                                  zh: '您最多只能同时参加3个挑战。',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: has
                                  ? const Color(0xFFEF4444)
                                  : (isFull
                                        ? const Color(0xFF374151)
                                        : const Color(0xFF00C896)),
                              disabledBackgroundColor: const Color(0xFF1F2937),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: (!has && isFull)
                                ? null
                                : () {
                                    setState(() {
                                      if (has) {
                                        _joinedIds.remove(item.id);
                                        item.current = 0.0;
                                        item.progress = 0.0;
                                      } else {
                                        _joinedIds.add(item.id);
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                            child: Text(
                              has
                                  ? AppLanguage.t(
                                      en: 'Give up challenge',
                                      ko: '챌린지 포기하기',
                                      ja: 'チャレンジを諦める',
                                      es: 'Abandonar desafío',
                                      zh: '放弃挑战',
                                    )
                                  : AppLanguage.t(
                                      en: 'Join this challenge',
                                      ko: '이 챌린지 도전하기',
                                      ja: 'このチャレンジに挑戦',
                                      es: 'Unirse a este desafío',
                                      zh: '参加此挑战',
                                    ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: has
                                    ? Colors.white
                                    : ((!has && isFull)
                                          ? const Color(0xFF6B7280)
                                          : const Color(0xFF0A0E1A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final joined = _allChallenges
        .where((c) => _joinedIds.contains(c.id))
        .toList();
    final available = _allChallenges
        .where((c) => !_joinedIds.contains(c.id))
        .toList();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLanguage.t(
                      en: 'Challenge',
                      ko: '챌린지',
                      ja: 'チャレンジ',
                      es: 'Desafío',
                      zh: '挑战',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${AppLanguage.t(en: 'Active Challenges', ko: '진행 중인 챌린지', ja: '進行中のチャレンジ', es: 'Desafíos activos', zh: '进行中的挑战')} (${joined.length}/3)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data() as Map?;
                          final hasTeam = data?['teamId'] != null;
                          return GestureDetector(
                            onTap: () {
                              if (hasTeam) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TeamOnboardingScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: hasTeam
                                    ? const Color(
                                        0xFF00C896,
                                      ).withValues(alpha: 0.1)
                                    : const Color(0xFF141824),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: hasTeam
                                      ? const Color(
                                          0xFF00C896,
                                        ).withValues(alpha: 0.4)
                                      : const Color(0xFF1E2535),
                                ),
                              ),
                              child: Text(
                                hasTeam
                                    ? (data?['teamName'] as String? ??
                                          AppLanguage.t(
                                            en: 'My Team',
                                            ko: '내 팀',
                                            ja: 'マイチーム',
                                            es: 'Mi Equipo',
                                            zh: '我的团队',
                                          ))
                                    : AppLanguage.t(
                                        en: 'Create Team',
                                        ko: '팀 만들기',
                                        ja: 'チーム作成',
                                        es: 'Crear Equipo',
                                        zh: '创建团队',
                                      ),
                                style: TextStyle(
                                  color: hasTeam
                                      ? const Color(0xFF00C896)
                                      : const Color(0xFF8899AA),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (joined.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        AppLanguage.t(
                          en: 'No active challenges.\nPick one below to get started!',
                          ko: '현재 도전 중인 챌린지가 없습니다.\n아래에서 마음에 드는 챌린지를 선택해 보세요.',
                          ja: '現在挑戦中のチャレンジはありません。\n下から気に入ったチャレンジを選んでください。',
                          es: 'No hay desafíos activos.\n¡Elige uno abajo para comenzar!',
                          zh: '当前没有进行中的挑战。\n在下方选择您喜欢的挑战开始吧！',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8899AA),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: joined.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = joined[index];
                        return _ChallengeCard(
                          challenge: item,
                          onTap: () => _show(item),
                        );
                      },
                    ),
                  const SizedBox(height: 28),
                  Text(
                    AppLanguage.t(
                      en: 'Challenges to cool off this summer',
                      ko: '여름을 시원하게 날려줄 챌린지',
                      ja: 'この夏を涼しくするチャレンジ',
                      es: 'Desafíos para refrescarte este verano',
                      zh: '让这个夏天清凉的挑战',
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: available.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = available[index];
                      return InkWell(
                        onTap: () => _show(item),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.goal,
                                      style: TextStyle(
                                        color: item.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF4A5568),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppLanguage.t(
                      en: 'Completed Challenges',
                      ko: '완료한 챌린지',
                      ja: '完了したチャレンジ',
                      es: 'Desafíos completados',
                      zh: '已完成的挑战',
                    ),
                    style: const TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _completedChallenges
                        .map((label) => _Badge(label))
                        .toList(),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 15,
            minBlastForce: 5,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.onTap});
  final ChallengeItem challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String unit =
        (challenge.titleKo.contains('회') || challenge.goalKo.contains('회'))
        ? AppLanguage.t(en: 'times', ko: '회', ja: '回', es: 'veces', zh: '次')
        : 'km';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: challenge.color,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${challenge.totalString}$unit',
                        style: const TextStyle(
                          color: Color(0xFF0A0E1A),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${challenge.daysLeft} ${AppLanguage.t(en: 'days left', ko: '일 남음', ja: '日残り', es: 'días restantes', zh: '天剩余')}',
                        style: TextStyle(
                          color: const Color(0xFF0A0E1A).withValues(alpha: 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    challenge.title,
                    style: const TextStyle(
                      color: Color(0xFF0A0E1A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${challenge.currentString} / ${challenge.totalString}',
                      style: TextStyle(
                        color: challenge.color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(challenge.progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFF8899AA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    backgroundColor: const Color(0xFF1E2535),
                    valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${AppLanguage.t(en: 'Reward', ko: '보상', ja: '報酬', es: 'Recompensa', zh: '奖励')}: ${challenge.reward}',
                  style: const TextStyle(
                    color: Color(0xFF8899AA),
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00C896).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00C896).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF00C896),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
