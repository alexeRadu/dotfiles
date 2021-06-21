import logging

def setup_logging():
    logger = logging.getLogger("dbug")

    handler = logging.FileHandler('/tmp/dbug.log', 'w')
    handler.formatter = logging.Formatter('%(msecs)6d %(levelname)-5s   %(message)s')
    logger.addHandler(handler)
    logger.setLevel(logging.DEBUG)
