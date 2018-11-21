class NewPostForm extends React.Component {
  constructor(props) {
    super(props);
    
    this.state = {
      title: '',
      slug: '',
      body: '',
      password: ''
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(event) {
    this.setState({
      [event.target.name]: event.target.value
    });
  }

  handleSubmit(event) {
    event.preventDefault();
    fetch('/new_blog_post', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(this.state)
    }).then(response => { window.location.href = '/' + this.state.slug; });
  }

  render() {
    return (
      <form onSubmit={this.handleSubmit}>
        <ul className='post_form'>
          <li>
            <label for='title'>Title</label>
            <input type='text' id='title' name='title' placeholder='New Post' value={this.state.title} onChange={this.handleChange} required/>
          </li>
          <li>
            <label for='slug'>Slug</label>
            <input type='text' id='slug' name='slug' placeholder='post_slug' value={this.state.slug} onChange={this.handleChange} required/>
          </li>
          <li>
            <label for='body'>Body</label>
            <textarea type='text' id='body' name='body' placeholder='Lorem ipsum' value={this.state.body} onChange={this.handleChange} required></textarea>
          </li>
          <li>
            <label for='password'>Password</label>
            <input type='password' id='password' name='password' value={this.state.password} onChange={this.handleChange} required/>
          </li>
          <li>
            <input type='submit' value='Submit'/>
          </li>
        </ul>
      </form>
    );
  }
}

ReactDOM.render(<NewPostForm />, document.getElementById('root'));