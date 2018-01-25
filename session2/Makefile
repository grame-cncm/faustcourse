Lessons = $(sort $(wildcard Lesson*.md))

session2.docx : $(Lessons)
	cat $(Lessons) > session2.md
	pandoc session2.md -o session2.docx
