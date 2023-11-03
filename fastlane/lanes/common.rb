# frozen_string_literal: true

desc 'Commit version bump for Expo projects'
private_lane :commit_expo_app_json do
  git_commit(path: ['app.json'], message: 'chore: Version bump')
end
