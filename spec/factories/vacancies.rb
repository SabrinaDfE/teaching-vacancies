FactoryGirl.define do
  factory :vacancy do
    association :pay_scale
    association :subject
    association :leadership
    association :school

    job_title { Faker::Job.title }
    headline { Faker::Lorem.sentence }
    working_pattern { :full_time }
    job_description { Faker::Lorem.paragraph(4) }
    essential_requirements { Faker::Lorem.paragraph(4) }
    status { :published }
    expires_on { Faker::Time.forward(14) }
    publish_on { Time.zone.today }
    minimum_salary { Faker::Number.number(4) }
    maximum_salary { Faker::Number.number(5) }
    contact_email { Faker::Internet.email }
    application_link { Faker::Internet.url }

    trait :complete do
      qualifications { Faker::Lorem.sentence }
      education { Faker::Lorem.sentence }
      experience { Faker::Lorem.sentence }

      starts_on { Faker::Time.forward(30) }
      ends_on { Faker::Time.forward(60) }
    end

    trait :draft do
      status { :draft }
    end

    trait :trashed do
      status { :trashed }
    end

    trait :published do
      status { :published }
    end

    trait :expired do
      expires_on { Faker::Time.backward(7) }
    end

    trait :job_schema do
      weekly_hours '8.5'
      education { Faker::Lorem.paragraph }
      benefits { Faker::Lorem.sentence }
    end
  end
end
