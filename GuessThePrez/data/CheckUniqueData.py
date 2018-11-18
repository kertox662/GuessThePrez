from sys import argv

with open(argv[1], "r") as f:
    x = [line.strip().split(",") for line in f]

for i in x:
    if i[0] == "President":
        continue
    for j in x:
        if j[0] == "President" or i == j:
            continue
        escape = False
        for k in range(len(i) - 1):
            # print(k+1)
            if i[k + 1] != j[k + 1]:
                escape = True
                break
        if escape == False:
            print(i[0], "Matches", j[0])
            break