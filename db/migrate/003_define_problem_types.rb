class DefineProblemTypes < ActiveRecord::Migration
  def self.up
    ProblemType.create(:name => "choose_1", :description => "Multiple Choice")
    ProblemType.create(:name => "choose_n", :description => "Check all that apply")
    ProblemType.create(:name => 'rank')
    ProblemType.create(:name => 'fill_in_1', :description => "Fill in")
    ProblemType.create(:name => 'algebra')
  end

  def self.down
    ProblemType.find_by_name('choose_1').destroy
    ProblemType.find_by_name("choose_n").destroy
    ProblemType.find_by_name('rank').destroy
    ProblemType.find_by_name('fill_in_1').destroy
    ProblemType.find_by_name('algebra').destroy
  end
end
