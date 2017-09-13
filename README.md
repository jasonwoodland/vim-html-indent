# vim-html-indent

HTML indent plugin for Vim. Based on [xml.vim](https://vim.sourceforge.io/scripts/script.php?script_id=1211).

Allows for automatic indentation of multiline element attributes, for example:

```html
<form action="/submit-form"
      method="post"
      name="myForm">

    <label for="fullname">Your name: </label>
    <input type="text"
           id="fullname"
           name="fullname"
           placeholder="Full name">

    <select name="sex">
        <option value="male">Male</option>
        <option value="female">Female</option>
    </select>

    <input type="submit" value="Send">
</form>
```

## Installation

If you have [pathogen](https://github.com/tpope/vim-pathogen) installed, simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/jasonwoodland/vim-html-indent.git
    
