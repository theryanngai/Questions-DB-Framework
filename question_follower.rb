class QuestionFollower
  attr_accessor :question_id, :follower_id, :id
  
  def initialize(options = {})
    @id, @question_id, @follower_id = 
      options.values_at('id', 'question_id', 'follower_id')
  end
  
  def create
    raise 'already saved!' unless self.id.nil?
    
    params = [@question_id, @follower_id]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
    INSERT INTO
      question_followers (question_id, follower_id)
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
      question_followers
    WHERE
      id = ?
    SQL
    
    results.map { |result| QuestionFollower.new(result) }
  end
  
  def self.followers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT DISTINCT 
      u.id, fname, lname
    FROM
      question_followers q 
    LEFT OUTER JOIN 
      users u
    ON
      follower_id = u.id
    WHERE
      q.question_id = ?
    SQL
    
    results.map { |result| User.new(result) }
  end
  
  def self.followed_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      q.id, q.title, q.body, q.author_id
    FROM
      question_followers qf
    LEFT OUTER JOIN 
      questions q
    ON
      question_id = q.id
    WHERE
      follower_id = ?
    SQL
    
    results.map { |result| Question.new(result) }
  end
  
  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT 
      q.id, q.title, q.body, q.author_id
    FROM
      questions q 
    LEFT OUTER JOIN
      question_followers qf
    ON
      q.id = qf.question_id
    GROUP BY
      q.id
    ORDER BY COUNT(*) DESC;
    SQL
    
    results[0...n].map { |result| Question.new(result) }
  end
  
end