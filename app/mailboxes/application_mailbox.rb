class ApplicationMailbox < ActionMailbox::Base
  routing all: :newsletters
end
