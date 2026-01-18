class ApplicationMailbox < ActionMailbox::Base
  routing(/\A[a-z0-9]{20}@/i => :newsletters)
end
