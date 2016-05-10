require 'spec_helper'

describe DbMeta do
  it 'has a version number' do
    expect(DbMeta::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
