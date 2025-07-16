from main import get_hello, main


def test_hello():
    assert get_hello() == "hello world!"

def test_main():
    main()
