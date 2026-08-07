double evaluationFactor(String? evaluation) {
  switch (evaluation) {
    case 'ممتاز':
      return 1.0;
    case 'جيد جداً':
      return 1.0;
    case 'جيد':
      return 1.0;
    case 'مقبول':
      return 1.0;
    case 'ضعيف':
      return 1.0;
    default:
      return 1.0;
  }
}