class WellnessActivity < ApplicationRecord
  enum activity_type: { 'Community Meeting': 1,
                        'Counselling': 2,
                        'Awareness': 3,
                        'Cyclathone': 4,
                        'Walkathone': 5,
                        'Zumba': 6,
                        'Meditation': 7,
                        'Special screening talk': 8,
                        'Health talk': 9,
                        'Sports activity': 10,
                        'Yoga': 11,
                        'Vaccination': 12,
                        'Water testing': 13 }
end
