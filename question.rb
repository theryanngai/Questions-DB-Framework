class Question
  attr_accessor :id, :title, :author_id, :body
  
  def initialize(options = {})
    @id, @title, @author_id, @body = 
      options.values_at('id', 'title', 'author_id', 'body')
  end
  
  def create
    raise 'already saved!' unless self.id.nil?
    
    params = [@title, @author_id, @body]
    QuestionsDatabase.instance.execute(<<-SQL, *params)
    INSERT INTO
      questions (title, author_id, body)
    VALUES
      (?, ?, ?)
    SQL
    
    @id = QuestionsDatabase.instance.last_insert_row_id 
  end
  
  def self.find_by_id(target_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, target_id)
    SELECT 
      * 
    FROM
      questions
    WHERE
      id = ?
    SQL
    
    results.map { |result| Question.new(result) }
  end
  
  def self.find_by_author_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, target_id)
    SELECT 
      * 
    FROM
      questions
    WHERE
      author_id = ?
    SQL
    results.map { |result| Question.new(result) }
  end
  
  def author
    User.find_by_id(@author_id)
  end 
  
  def replies
    Replies.find_by_question_id(@id)
  end
  
  def followers
    QuestionFollower.followers_for_question_id(@id)
  end
  
  def self.most_followed(n)
    QuestionFollower.most_followed_questions(n)
  end
  
  def likers
    QuestionLikes.likers_for_question_id(@id)
  end
  
  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end
  
  def self.most_liked(n)
    QuestionLikes.most_liked_questions(n)
  end
end