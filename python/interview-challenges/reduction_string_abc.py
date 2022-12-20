def Reduce(first, second):
    allowed_chars = ['a', 'b', 'c']
    if first in allowed_chars:
        allowed_chars.remove(first)
    if second in allowed_chars:
        allowed_chars.remove(second)
    return allowed_chars[0]

def StringReduction(strParam):
    strArr = list(strParam)
    i = 0
    while i < len(strArr):
        if i < len(strArr)-1 and strArr[i] != strArr[i+1]:
            reduce_to = Reduce(strArr[i], strArr[i+1])
            strArr.pop(0)
            strArr[0] = reduce_to
            i -= 1
        i += 1
    return len(strArr)

print(StringReduction("abcabc"))
