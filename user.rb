require 'debugger'

class User
  attr_accessor :fname, :lname, :id
  
  def initialize(options = {})
    @id, @fname, @lname = 
      options.values_at('id', 'fname', 'lname')
  end
  
  def create
    raise 'already saved!' unless self.id.nil?
    
    params = [@fname, @lname] 
    QuestionsDatabase.instance.execute(<<-SQL, *params)
    INSERT INTO
      users (fname, lname)
    VALUES
      (?, ?)
    SQL
    
    @id = QuestionsDatabase.instance.last_insert_row_id 
  end
  
  def self.find_by_id(target_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, target_id)
    SELECT 
      * 
    FROM
      users
    WHERE
      id = ?
    SQL
    
    results.map { |result| User.new(result) }
  end
  
  def self.find_by_name(fname, lname)
    results = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
    SELECT
      *
    FROM
      users
    WHERE
      fname = ? AND lname = ?
    SQL
    results.map { |result| User.new(result) }
  end
  
  def self.average_karma(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      AVG(num_likes)
    FROM
      (SELECT 
         COUNT(*) AS num_likes 
       FROM 
         questions q 
       LEFT OUTER JOIN 
         question_likes ql 
       ON 
         q.id = ql.question_id 
       GROUP BY 
         question_id 
       HAVING 
         author_id = ?) 
    SQL
    results.first.values.first
  end
  
  def authored_questions
    Question.find_by_author_id(@id)
  end
  
  def authored_replies
    Replies.find_by_user_id(@id)
  end
  
  def followed_questions
    QuestionFollower.followed_questions_for_user_id(@id)
  end
  
  def liked_questions
    QuestionLikes.liked_questions_for_user_id(@id)
  end
  
  def save
    
    params = {:fname => @fname, :lname => @lname, :id => @id }
    if @id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, params)
      INSERT INTO
        users (fname, lname)
      VALUES
        (:fname, :lname)
      SQL
      
      @id = QuestionsDatabase.instance.last_insert_row_id 
    else
      QuestionsDatabase.instance.execute(<<-SQL, params)
      UPDATE 
        users 
      SET
        fname = :fname, lname = :lname
      WHERE
        id = :id
      SQL
    end
  end  
end
