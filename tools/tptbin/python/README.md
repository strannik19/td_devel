Here are some tools for the binary format of TPT (Teradata Parallel Transporter).

They usually operate on files, so no piping is currently supported.

Every record **must** follow the format:

1. Two bytes store the length of one logical record (this two bytes are not included in the record length)
2. (Optional) Null indicator. For every 8 columns one byte. A set bit indicates a null column. From left to right.
3. Two bytes store the length of the next column (if field is null (indicated by null indicator)), this two bytes are still required.
4. Content of the column

No Carriage Return or alike is required.

# tptbinrc.py

Rowcount of TPT binary files. Output is like from `wc -l`

# tptbincheck.py

Try to determine number of columns per row.
