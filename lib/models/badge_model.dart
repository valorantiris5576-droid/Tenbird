import 'package:flutter/material.dart';

class BadgeModel {
  final String id;
  final String nameEn;
  final String nameKo;
  final String nameJa;
  final String nameEs;
  final String nameZh;
  final String descEn;
  final String descKo;
  final String descJa;
  final String descEs;
  final String descZh;
  final String icon;
  final BadgeRarity rarity;
  final BadgeCondition condition;
  final bool hidden;

  const BadgeModel({
    required this.id,
    required this.nameEn,
    required this.nameKo,
    required this.nameJa,
    required this.nameEs,
    required this.nameZh,
    required this.descEn,
    required this.descKo,
    required this.descJa,
    required this.descEs,
    required this.descZh,
    required this.icon,
    required this.rarity,
    required this.condition,
    this.hidden = false,
  });

  String get name => _t(nameEn, nameKo, nameJa, nameEs, nameZh);
  String get desc => _t(descEn, descKo, descJa, descEs, descZh);

  static String _t(String en, String ko, String ja, String es, String zh) {
    switch (_lang) {
      case 'ko':
        return ko;
      case 'ja':
        return ja;
      case 'es':
        return es;
      case 'zh':
        return zh;
      default:
        return en;
    }
  }

  static String _lang = 'en';
  static void setLang(String lang) => _lang = lang;
}

enum BadgeRarity { common, rare, epic, legendary }

enum BadgeCondition {
  firstRun,
  run5km,
  run10km,
  run42km,
  run100km,
  run7days,
  teamFounder,
  teamMember,
  friendAdded,
  challenge1,
  challenge3,
  donationFirst,
  donation1000,
  donation10000,
  hiddenNightOwl,
  hiddenEarlyBird,
  hiddenMarathon,
}

class BadgeData {
  static const List<BadgeModel> all = [
    BadgeModel(
      id: 'first_run',
      nameEn: 'First Step',
      nameKo: '첫 발걸음',
      nameJa: 'ファーストステップ',
      nameEs: 'Primer Paso',
      nameZh: '第一步',
      descEn: 'Complete your first run',
      descKo: '첫 러닝을 완료했어요',
      descJa: '初めてのランニングを完了',
      descEs: 'Completa tu primera carrera',
      descZh: '完成第一次跑步',
      icon: 'assets/badges/first_run.png',
      rarity: BadgeRarity.common,
      condition: BadgeCondition.firstRun,
    ),
    BadgeModel(
      id: 'run_5km',
      nameEn: '5K Runner',
      nameKo: '5K 러너',
      nameJa: '5Kランナー',
      nameEs: 'Corredor 5K',
      nameZh: '5K跑者',
      descEn: 'Run a total of 5km',
      descKo: '누적 5km 달성',
      descJa: '累計5km達成',
      descEs: 'Corre un total de 5km',
      descZh: '累计跑5公里',
      icon: 'assets/badges/run_5km.png',
      rarity: BadgeRarity.common,
      condition: BadgeCondition.run5km,
    ),
    BadgeModel(
      id: 'run_10km',
      nameEn: '10K Runner',
      nameKo: '10K 러너',
      nameJa: '10Kランナー',
      nameEs: 'Corredor 10K',
      nameZh: '10K跑者',
      descEn: 'Run a total of 10km',
      descKo: '누적 10km 달성',
      descJa: '累計10km達成',
      descEs: 'Corre un total de 10km',
      descZh: '累计跑10公里',
      icon: 'assets/badges/run_10km.png',
      rarity: BadgeRarity.rare,
      condition: BadgeCondition.run10km,
    ),
    BadgeModel(
      id: 'run_42km',
      nameEn: 'Marathoner',
      nameKo: '마라토너',
      nameJa: 'マラソナー',
      nameEs: 'Maratonista',
      nameZh: '马拉松手',
      descEn: 'Run a total of 42.195km',
      descKo: '누적 42.195km 달성',
      descJa: '累計42.195km達成',
      descEs: 'Corre un total de 42.195km',
      descZh: '累计跑42.195公里',
      icon: 'assets/badges/run_42km.png',
      rarity: BadgeRarity.epic,
      condition: BadgeCondition.run42km,
    ),
    BadgeModel(
      id: 'run_100km',
      nameEn: 'Century Runner',
      nameKo: '센추리 러너',
      nameJa: 'センチュリーランナー',
      nameEs: 'Corredor Centenario',
      nameZh: '百公里跑者',
      descEn: 'Run a total of 100km',
      descKo: '누적 100km 달성',
      descJa: '累計100km達成',
      descEs: 'Corre un total de 100km',
      descZh: '累计跑100公里',
      icon: 'assets/badges/run_100km.png',
      rarity: BadgeRarity.legendary,
      condition: BadgeCondition.run100km,
    ),
    BadgeModel(
      id: 'run_7days',
      nameEn: 'GOD Lifer',
      nameKo: '갓생러',
      nameJa: 'GOD生',
      nameEs: 'Vida Perfecta',
      nameZh: '完美生活者',
      descEn: 'Run 7 days in a row',
      descKo: '7일 연속 러닝',
      descJa: '7日連続ランニング',
      descEs: 'Corre 7 días seguidos',
      descZh: '连续7天跑步',
      icon: 'assets/badges/run_7days.png',
      rarity: BadgeRarity.rare,
      condition: BadgeCondition.run7days,
    ),
    BadgeModel(
      id: 'team_founder',
      nameEn: 'Team Founder',
      nameKo: '팀 창단자',
      nameJa: 'チーム創設者',
      nameEs: 'Fundador de Equipo',
      nameZh: '团队创始人',
      descEn: 'Create your first team',
      descKo: '팀을 처음으로 만들었어요',
      descJa: '初めてチームを作った',
      descEs: 'Crea tu primer equipo',
      descZh: '创建了第一个团队',
      icon: 'assets/badges/team_founder.png',
      rarity: BadgeRarity.epic,
      condition: BadgeCondition.teamFounder,
    ),
    BadgeModel(
      id: 'team_member',
      nameEn: 'Team Player',
      nameKo: '팀 플레이어',
      nameJa: 'チームプレイヤー',
      nameEs: 'Jugador de Equipo',
      nameZh: '团队成员',
      descEn: 'Join a team',
      descKo: '팀에 가입했어요',
      descJa: 'チームに参加した',
      descEs: 'Únete a un equipo',
      descZh: '加入了团队',
      icon: 'assets/badges/team_member.png',
      rarity: BadgeRarity.common,
      condition: BadgeCondition.teamMember,
    ),
    BadgeModel(
      id: 'friend_added',
      nameEn: 'Social Runner',
      nameKo: '소셜 러너',
      nameJa: 'ソーシャルランナー',
      nameEs: 'Corredor Social',
      nameZh: '社交跑者',
      descEn: 'Add your first friend',
      descKo: '첫 친구를 추가했어요',
      descJa: '初めて友達を追加した',
      descEs: 'Agrega tu primer amigo',
      descZh: '添加了第一个好友',
      icon: 'assets/badges/friend_added.png',
      rarity: BadgeRarity.common,
      condition: BadgeCondition.friendAdded,
    ),
    BadgeModel(
      id: 'challenge_1',
      nameEn: 'Challenger',
      nameKo: '챌린저',
      nameJa: 'チャレンジャー',
      nameEs: 'Desafiante',
      nameZh: '挑战者',
      descEn: 'Complete your first challenge',
      descKo: '첫 챌린지를 완료했어요',
      descJa: '初めてのチャレンジを完了',
      descEs: 'Completa tu primer desafío',
      descZh: '完成第一个挑战',
      icon: 'assets/badges/challenge_1.png',
      rarity: BadgeRarity.rare,
      condition: BadgeCondition.challenge1,
    ),
    BadgeModel(
      id: 'challenge_3',
      nameEn: 'Triple Threat',
      nameKo: '트리플 스레트',
      nameJa: 'トリプルスレット',
      nameEs: 'Triple Amenaza',
      nameZh: '三重威胁',
      descEn: 'Complete 3 challenges',
      descKo: '챌린지 3개 완료',
      descJa: 'チャレンジ3つ完了',
      descEs: 'Completa 3 desafíos',
      descZh: '完成3个挑战',
      icon: 'assets/badges/challenge_3.png',
      rarity: BadgeRarity.epic,
      condition: BadgeCondition.challenge3,
    ),
    BadgeModel(
      id: 'donation_first',
      nameEn: 'Kind Heart',
      nameKo: '따뜻한 마음',
      nameJa: '温かい心',
      nameEs: 'Corazón Amable',
      nameZh: '善良的心',
      descEn: 'Make your first donation',
      descKo: '첫 기부를 했어요',
      descJa: '初めての寄付をした',
      descEs: 'Haz tu primera donación',
      descZh: '完成第一次捐款',
      icon: 'assets/badges/donation_first.png',
      rarity: BadgeRarity.common,
      condition: BadgeCondition.donationFirst,
    ),
    BadgeModel(
      id: 'donation_1000',
      nameEn: 'Generous Runner',
      nameKo: '관대한 러너',
      nameJa: '寛大なランナー',
      nameEs: 'Corredor Generoso',
      nameZh: '慷慨跑者',
      descEn: 'Donate a total of 1,000 won',
      descKo: '총 1,000원 기부',
      descJa: '合計1,000ウォン寄付',
      descEs: 'Dona un total de 1,000 won',
      descZh: '总捐款1000韩元',
      icon: 'assets/badges/donation_1000.png',
      rarity: BadgeRarity.rare,
      condition: BadgeCondition.donation1000,
    ),
    BadgeModel(
      id: 'donation_10000',
      nameEn: 'Philanthropist',
      nameKo: '자선가',
      nameJa: '慈善家',
      nameEs: 'Filántropo',
      nameZh: '慈善家',
      descEn: 'Donate a total of 10,000 won',
      descKo: '총 10,000원 기부',
      descJa: '合計10,000ウォン寄付',
      descEs: 'Dona un total de 10,000 won',
      descZh: '总捐款10000韩元',
      icon: 'assets/badges/donation_10000.png',
      rarity: BadgeRarity.legendary,
      condition: BadgeCondition.donation10000,
    ),
    BadgeModel(
      id: 'hidden_night_owl',
      nameEn: 'Night Owl',
      nameKo: '올빼미',
      nameJa: 'ナイトオウル',
      nameEs: 'Búho Nocturno',
      nameZh: '夜猫子',
      descEn: 'Run after midnight 3 times',
      descKo: '자정 이후 러닝 3회',
      descJa: '深夜0時以降のランニング3回',
      descEs: 'Corre después de medianoche 3 veces',
      descZh: '午夜后跑步3次',
      icon: 'assets/badges/hidden_night_owl.png',
      rarity: BadgeRarity.epic,
      condition: BadgeCondition.hiddenNightOwl,
      hidden: true,
    ),
    BadgeModel(
      id: 'hidden_early_bird',
      nameEn: 'Early Bird',
      nameKo: '얼리버드',
      nameJa: 'アーリーバード',
      nameEs: 'Madrugador',
      nameZh: '早起鸟',
      descEn: 'Run before 6AM 5 times',
      descKo: '오전 6시 이전 러닝 5회',
      descJa: '午前6時前のランニング5回',
      descEs: 'Corre antes de las 6AM 5 veces',
      descZh: '早上6点前跑步5次',
      icon: 'assets/badges/hidden_early_bird.png',
      rarity: BadgeRarity.epic,
      condition: BadgeCondition.hiddenEarlyBird,
      hidden: true,
    ),
    BadgeModel(
      id: 'hidden_marathon',
      nameEn: 'Silent Marathoner',
      nameKo: '조용한 마라토너',
      nameJa: 'サイレントマラソナー',
      nameEs: 'Maratonista Silencioso',
      nameZh: '沉默的马拉松手',
      descEn: 'Run 42km without joining any challenge',
      descKo: '챌린지 없이 42km 달성',
      descJa: 'チャレンジなしで42km達成',
      descEs: 'Corre 42km sin unirte a ningún desafío',
      descZh: '不参加任何挑战完成42公里',
      icon: 'assets/badges/hidden_marathon.png',
      rarity: BadgeRarity.legendary,
      condition: BadgeCondition.hiddenMarathon,
      hidden: true,
    ),
  ];

  static BadgeModel? getById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  static Color rarityColor(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return const Color(0xFF8899AA);
      case BadgeRarity.rare:
        return const Color(0xFF3B82F6);
      case BadgeRarity.epic:
        return const Color(0xFF8B5CF6);
      case BadgeRarity.legendary:
        return const Color(0xFFFFB300);
    }
  }

  static String rarityName(BadgeRarity rarity) {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Common';
      case BadgeRarity.rare:
        return 'Rare';
      case BadgeRarity.epic:
        return 'Epic';
      case BadgeRarity.legendary:
        return 'Legendary';
    }
  }
}
