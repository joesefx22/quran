double evaluationFactor(String? evaluation) {
  switch (evaluation) {
    case 'ممتاز':
      return 1.0;
    case 'جيد جداً':
      return 0.9;
    case 'جيد':
      return 0.8;
    case 'مقبول':
      return 0.7;
    case 'ضعيف':
      return 0.3;
    default:
      return 1.0;
  }
}