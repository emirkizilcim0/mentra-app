// personality_data.dart

import 'package:flutter/material.dart';
import 'package:mentra_app/mbti/result_screen.dart';

// Kişilik sonuç verilerini taşımak için model sınıfı
class PersonalityResult {
  final String type; // Örn: 'ENFJ'
  final String title; // Örn: 'Kahraman'
  final String description;
  final Color color;

  PersonalityResult({
    required this.type,
    required this.title,
    required this.description,
    required this.color,
  });
}

// Tüm 16 kişilik tipi için veri seti
final Map<String, PersonalityResult> personalityData = {
  // Analistler (Mavi tonlar)
  'INTJ': PersonalityResult(
    type: 'INTJ',
    title: 'The Architect',
    description:
        'Have original minds and great drive for implementing their ideas and achieving their goals. Quickly see patterns in external events and develop long-range explanatory perspectives. When committed, organize a job and carry it through. Skeptical and independent, have high standards of competence and performance—for themselves and others.',
    color: Colors.indigo.shade700,
  ),
  'INTP': PersonalityResult(
    type: 'INTP',
    title: 'The Thinker',
    description:
        'Seek to develop logical explanations for everything that interests them. Theoretical and abstract, interested more in ideas than in social interaction. Quiet, contained, flexible, and adaptable. Have unusual ability to focus in depth to solve problems in their area of interest. Skeptical, sometimes critical, always analytical.',
    color: Colors.blueGrey.shade700,
  ),
  'ENTJ': PersonalityResult(
    type: 'ENTJ',
    title: 'The Commander',
    description:
        'Frank, decisive, assume leadership readily. Quickly see illogical and inefficient procedures and policies, develop and implement comprehensive systems to solve organizational problems. Enjoy long-term planning and goal setting. Usually well informed, well read, enjoy expanding their knowledge and passing it on to others. Forceful in presenting their ideas.',
    color: Colors.blue.shade700,
  ),
  'ENTP': PersonalityResult(
    type: 'ENTP',
    title: 'The Debater',
    description:
        'Quick, ingenious, stimulating, alert, and outspoken. Resourceful in solving new and challenging problems. Adept at generating conceptual possibilities and then analyzing them strategically. Good at reading other people. Bored by routine, will seldom do the same thing the same way, apt to turn to one new interest after another.',
    color: Colors.cyan.shade700,
  ),

  // Diplomatlar (Yeşil tonlar)
  'INFJ': PersonalityResult(
    type: 'INFJ',
    title: 'The Advocate',
    description:
        'Seek meaning and connection in ideas, relationships, and material possessions. Want to understand what motivates people and are insightful about others. Conscientious and committed to their firm values. Develop a clear vision about how best to serve the common good. Organized and decisive in implementing their vision.',
    color: Colors.teal.shade700,
  ),
  'INFP': PersonalityResult(
    type: 'INFP',
    title: 'The Idealist',
    description:
        'Idealistic, loyal to their values and to people who are important to them. Want to live a life that is congruent with their values. Curious, quick to see possibilities, can be catalysts for implementing ideas. Seek to understand people and to help them fulfill their potential. Adaptable, flexible, and accepting unless a value is threatened.',
    color: Colors.lightGreen.shade700,
  ),
  'ENFJ': PersonalityResult(
    type: 'ENFJ',
    title: 'Protagonist',
    description:
        'Warm, empathetic, responsive, and responsible. Highly attuned to the emotions, needs, and motivations of others. Find potential in everyone, want to help others fulfill their potential. May act as catalysts for individual and group growth. Loyal, responsive to praise and criticism. Sociable, facilitate others in a group, and provide inspiring leadership.',
    color: Colors.green.shade700,
  ),
  'ENFP': PersonalityResult(
    type: 'ENFP',
    title: 'The Campaigner',
    description:
        'Warmly enthusiastic and imaginative. See life as full of possibilities. Make connections between events and information very quickly, and confidently proceed based on the patterns they see. Want a lot of affirmation from others, and readily give appreciation and support. Spontaneous and flexible, often rely on their ability to improvise and their verbal fluency.',
    color: Colors.lime.shade700,
  ),

  // Gözcüler (Sarı/Turuncu tonlar)
  'ISTJ': PersonalityResult(
    type: 'ISTJ',
    title: 'The Logistician',
    description:
        'Quiet, serious, earn success by being thorough and dependable. Practical, matter-of-fact, realistic, and responsible. Decide logically what should be done and work toward it steadily, regardless of distractions. Take pleasure in making everything orderly and organized—their work, their home, their life. Value traditions and loyalty.',
    color: Colors.brown.shade700,
  ),
  'ISFJ': PersonalityResult(
    type: 'ISFJ',
    title: 'The Defender',
    description:
        'Quiet, friendly, responsible, and conscientious. Committed and steady in meeting their obligations. Thorough, painstaking, and accurate. Loyal, considerate, notice and remember specifics about people who are important to them, concerned with how others feel. Strive to create an orderly and harmonious environment at work and at home.',
    color: Colors.amber.shade700,
  ),
  'ESTJ': PersonalityResult(
    type: 'ESTJ',
    title: 'The Director',
    description:
        'Practical, realistic, matter-of-fact. Decisive, quickly move to implement decisions. Organize projects and people to get things done, focus on getting results in the most efficient way possible. Take care of routine details. Have a clear set of logical standards, systematically follow them and want others to also. Forceful in implementing their plans.',
    color: Colors.orange.shade700,
  ),
  'ESFJ': PersonalityResult(
    type: 'ESFJ',
    title: 'The Consul',
    description:
        'Warmhearted, conscientious, and cooperative. Want harmony in their environment, work with determination to establish it. Like to work with others to complete tasks accurately and on time. Loyal, follow through even in small matters. Notice what others need in their day-to-day lives and try to provide it. Want to be appreciated for who they are and for what they contribute.',
    color: Colors.deepOrange.shade700,
  ),

  // Kaşifler (Kırmızı/Gri tonlar)
  'ISTP': PersonalityResult(
    type: 'ISTP',
    title: 'The Crafter',
    description:
        'Tolerant and flexible, quiet observers until a problem appears, then act quickly to find workable solutions. Analyze what makes things work and readily get through large amounts of data to isolate the core of practical problems. Interested in cause and effect, organize facts using logical principles, value efficiency.',
    color: Colors.grey.shade700,
  ),
  'ISFP': PersonalityResult(
    type: 'ISFP',
    title: 'The Adventurer',
    description:
        'Quiet, friendly, sensitive, and kind. Enjoy the present moment, what is going on around them. Like to have their own space and to work within their own time frame. Loyal and committed to their values and to people who are important to them. Dislike disagreements and conflicts; do nott force their opinions or values on others.',
    color: Colors.pink.shade700,
  ),
  'ESTP': PersonalityResult(
    type: 'ESTP',
    title: 'The Entrepreneur',
    description:
        'Flexible and tolerant, take a pragmatic approach focused on immediate results. Bored by theories and conceptual explanations; want to act energetically to solve the problem. Focus on the here and now, spontaneous, enjoy each moment they can be active with others. Enjoy material comforts and style. Learn best through doing.',
    color: Colors.red.shade700,
  ),
  'ESFP': PersonalityResult(
    type: 'ESFP',
    title: 'The Entertainer',
    description:
        'Outgoing, friendly, and accepting. Exuberant lovers of life, people, and material comforts. Enjoy working with others to make things happen. Bring common sense and a realistic approach to their work and make work fun. Flexible and spontaneous, adapt readily to new people and environments. Learn best by trying a new skill with other people.',
    color: Colors.purple.shade700,
  ),
};
