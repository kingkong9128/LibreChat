FROM node:20-alpine
WORKDIR /app
RUN echo "hello world" > test.txt
CMD ["cat", "test.txt"]