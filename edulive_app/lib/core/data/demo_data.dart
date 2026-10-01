class StudyClass {
  const StudyClass(this.title, this.subject, this.teacher, this.time, {this.live = false});
  final String title, subject, teacher, time;
  final bool live;
}

const classes = [
  StudyClass('Introduction to Trigonometry', 'Mathematics', 'BSGD Academy Faculty', 'Today • 7:30 PM', live: true),
  StudyClass('Understanding Newton’s Laws', 'Physics', 'BSGD Academy Faculty', 'Tomorrow • 5:00 PM'),
  StudyClass('Grammar: Sentence Structure', 'English', 'BSGD Academy Faculty', 'Friday • 8:00 PM'),
];

class Lesson {
  const Lesson(this.title, this.subject, this.duration, this.emoji);
  final String title, subject, duration, emoji;
}

const lessons = [
  Lesson('Trigonometry: The Basics', 'Mathematics', '18 min', '📐'),
  Lesson('Forces and Motion', 'Physics', '24 min', '🚀'),
  Lesson('Writing a Great Paragraph', 'English', '12 min', '✍️'),
];
