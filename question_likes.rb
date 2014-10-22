class QuestionLikes
  attr_accessor :question_id, :liker_id, :id
  
  def initialize(options = {})
    @id, @question_id, @liker_id = 
      options.values_at('id', 'question_id', 'liker_id')
  end
  
  def create
    raise 'already saved!' unless self.id.nil?
    
    params = [@question_id, @liker_id]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
    INSERT INTO
      question_likes (question_id, liker_id)
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
      question_likes
    WHERE
      id = ?
    SQL
    
    results.map { |result| QuestionLikes.new(result) }
  end
  
  def self.likers_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT 
      u.id, fname, lname
    FROM
      question_likes q
    LEFT OUTER JOIN
      users u
    ON
      u.id = liker_id  
    WHERE
      q.question_id = ?
    SQL
    
    results.map { |result| User.new(result) }
  end
  
  def self.num_likes_for_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT 
      COUNT (*)
    FROM
      question_likes q
    LEFT OUTER JOIN
      users u
    ON
      u.id = liker_id  
    WHERE
      q.question_id = ?
    SQL
    
    results.first.values.first
  end
  
  def self.liked_questions_for_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT 
      q.id, q.title, q.author_id, q.body
    FROM
      question_likes ql
    LEFT OUTER JOIN
      questions q
    ON
      question_id = q.id  
    WHERE
      liker_id = ?
    SQL
    
    results.map { |result| Question.new(result) }
  end
  
  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
    SELECT 
      q.id, q.title, q.body, q.author_id
    FROM
      questions q 
    LEFT OUTER JOIN
      question_likes ql
    ON
      q.id = ql.question_id
    GROUP BY
      q.id
    ORDER BY COUNT(*) DESC;
    SQL
    
    results[0...n].map { |result| Question.new(result) }
  end
end