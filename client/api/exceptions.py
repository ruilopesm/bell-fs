class UnauthorizedAccessException(Exception):
    def __init__(self, message='Token may be invalid or expired.'):
        super().__init__(message)