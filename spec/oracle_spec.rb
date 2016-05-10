require 'spec_helper'

describe DbMeta::Oracle do


  it 'has a table type' do
    object = DbMeta::Oracle::Base.from_type(:table)
    expect(object.class).to eq(DbMeta::Oracle::Table)
  end

  it "fails with unknown oracle type" do
    expect {
      object = DbMeta::Oracle::Base.from_type(:unknown)
    }.to raise_error(RuntimeError, 'Oracle type [unknown] is unknown')

  end

end
