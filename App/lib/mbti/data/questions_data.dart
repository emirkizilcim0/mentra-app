import 'dart:convert';
import '../models/question.dart';


const String mbtiJsonString = r'''
[
  {
    "no": 1,
    "question": "At a party, I interact with many people, including strangers.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 2,
    "question": "I am more realistic than speculative.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 3,
    "question": "It is worse to have my head in the clouds than to be in a rut.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 4,
    "question": "I am more impressed by principles than emotions.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 5,
    "question": "I am more drawn toward convincing arguments than touching ones.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 6,
    "question": "I prefer to work according to deadlines.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 7,
    "question": "I tend to choose things carefully rather than impulsively.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 8,
    "question": "At parties, I stay late with increasing energy.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 9,
    "question": "I am more attracted to sensible people than imaginative ones.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 10,
    "question": "I am more interested in what is actual than what is possible.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 11,
    "question": "In judging others, I am more swayed by laws than circumstances.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 12,
    "question": "When approaching others, I tend to be objective rather than personal.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 13,
    "question": "I am usually punctual rather than leisurely.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 14,
    "question": "It bothers me more to have things incomplete than completed.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 15,
    "question": "In my social groups, I keep up with others’ happenings.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 16,
    "question": "In ordinary tasks, I prefer doing things the usual way.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 17,
    "question": "Writers should say what they mean and mean what they say.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 18,
    "question": "Consistency of thought impresses me more than harmonious relationships.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 19,
    "question": "I am more comfortable making logical judgments than value judgments.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 20,
    "question": "I prefer things settled and decided.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 21,
    "question": "I tend to be serious and determined rather than easy-going.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 22,
    "question": "When phoning, I rarely rehearse what I will say.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 23,
    "question": "Facts speak for themselves rather than illustrating principles.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 24,
    "question": "Visionaries are somewhat annoying.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 25,
    "question": "I am more often a cool-headed person than warm-hearted.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 26,
    "question": "It is worse to be unjust than merciless.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 27,
    "question": "Events should occur by careful selection and choice.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 28,
    "question": "I feel better after having purchased something than having the option to buy.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 29,
    "question": "In company, I initiate conversation.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 30,
    "question": "Common sense is rarely questionable.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 31,
    "question": "Children often do not make themselves useful enough.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 32,
    "question": "In decisions, I am more comfortable with standards than feelings.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 33,
    "question": "I am more firm than gentle.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 34,
    "question": "The ability to organize and be methodical is more admirable.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 35,
    "question": "I value being methodical and consistent more than open-minded.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 36,
    "question": "New, non-routine interaction with others stimulates me.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 37,
    "question": "I am more practical than fanciful.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 38,
    "question": "I see how others are useful rather than how they see.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 39,
    "question": "It is more satisfying to discuss an issue thoroughly than to reach agreement.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 40,
    "question": "My head rules me more than my heart.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 41,
    "question": "I am more comfortable with contracted work than casual work.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 42,
    "question": "I tend to look for the orderly rather than whatever turns up.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 43,
    "question": "I prefer having many friends with brief contact.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 44,
    "question": "I go more by facts than principles.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 45,
    "question": "I am more interested in production and distribution than design and research.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 46,
    "question": "Being called logical is more of a compliment than sentimental.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 47,
    "question": "I value being unwavering more than devoted.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 48,
    "question": "I prefer final and unalterable statements to tentative ones.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 49,
    "question": "I feel more comfortable after a decision than before.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 50,
    "question": "I speak easily and at length with strangers.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 51,
    "question": "I trust my experience more than my hunches.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 52,
    "question": "I feel more practical than ingenious.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 53,
    "question": "I compliment people with clear reason more than strong feeling.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 54,
    "question": "I am more fair-minded than sympathetic.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 55,
    "question": "It is preferable to make sure things are arranged.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 56,
    "question": "In relationships, I prefer things to be re-negotiable.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 57,
    "question": "When the phone rings, I hasten to answer it first.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 58,
    "question": "I prize having a strong sense of reality over a vivid imagination.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 59,
    "question": "I am drawn more to fundamentals than overtones.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 60,
    "question": "It is a greater error to be too passionate than too objective.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 61,
    "question": "I see myself as hard-headed rather than soft-hearted.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 62,
    "question": "The structured and scheduled appeals to me more than the unstructured.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 63,
    "question": "I am more routinized than whimsical.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 64,
    "question": "I am easy to approach rather than reserved.",
    "dimension": "E/I",
    "score_type": "E",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 65,
    "question": "In writings, I prefer the more literal than the figurative.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 66,
    "question": "It is harder for me to identify with others than to utilize them.",
    "dimension": "S/N",
    "score_type": "S",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 67,
    "question": "I wish for clarity of reason more than strength of compassion.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 68,
    "question": "It is a greater fault to be indiscriminate than critical.",
    "dimension": "T/F",
    "score_type": "T",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 69,
    "question": "I prefer planned events over unplanned ones.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  },
  {
    "no": 70,
    "question": "I am more deliberate than spontaneous.",
    "dimension": "J/P",
    "score_type": "J",
    "choices": [
      {
        "label": "Strongly Disagree",
        "value": -2
      },
      {
        "label": "Disagree",
        "value": -1
      },
      {
        "label": "Neutral",
        "value": 0
      },
      {
        "label": "Agree",
        "value": 1
      },
      {
        "label": "Strongly Agree",
        "value": 2
      }
    ]
  }
]
''';

// JSON string'i Dart nesnelerine dönüştürme fonksiyonu
List<Question> loadQuestions() {
  final List<dynamic> jsonList = jsonDecode(mbtiJsonString);
  return jsonList.map((json) => Question.fromJson(json)).toList();
}

final List<Question> mbtiQuestions = loadQuestions();
