class Replies
  attr_accessor :id, :body, :question_id, :parent_id, :author_id

  def initialize(options = {})
    @id, @body, @question_id, @parent_id, @author_id =
      options.values_at('id', 'body', 'question_id', 'parent_id', 'author_id')
  end

  def create
    raise 'already saved!' unless self.id.nil?
  
    params = [@body, @question_id, @parent_id, @author_id]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
    INSERT INTO
      replies ('body', 'question_id', 'parent_id', 'author_id')
    VALUES
      (?, ?, ?, ?)
    SQL
  
    @id = QuestionsDatabase.instance.last_insert_row_id 
  end

  def self.find_by_id(target_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, target_id)
    SELECT 
      * 
    FROM
      replies
    WHERE
      id = ?
    SQL
  
    results.map { |result| Replies.new(result) }
  end
  
  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT 
      * 
    FROM
      replies
    WHERE
      question_id = ?
    SQL
  
    results.map { |result| Replies.new(result) }
    
  end
  
  def self.find_by_user_id(user_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT 
      * 
    FROM
      replies
    WHERE
      author_id = ?
    SQL
  
    results.map { |result| Replies.new(result) }
  end
  
  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, @id)
    SELECT 
      * 
    FROM
      replies
    WHERE
      parent_id = ?
    SQL
  
    results.map { |result| Replies.new(result) }
  end
  
  
  def author
    User.find_by_id(@author_id)
  end
  
  def question
    Question.find_by_id(@question_id)
  end
  
  def parent_reply
    Replies.find_by_id(@parent_id)
  end
  
 
end
