import json
from pathlib import Path

def ex(id, name, muscle, sets, reps, rest=90, drop=False, fail=False, notes=None, tips=None, video=None):
    o = {"id": id, "name": name, "muscleGroup": muscle, "sets": sets, "reps": reps, "restSeconds": rest}
    if drop:
        o["isDropSet"] = True
    if fail:
        o["isFail"] = True
    if notes:
        o["notes"] = notes
    if tips:
        o["tips"] = tips
    if video:
        o["videoUrl"] = video
    return o

def day(id, num, name, muscle, mins, exercises, desc=None):
    d = {
        "id": id,
        "dayNumber": num,
        "name": name,
        "muscleGroup": muscle,
        "estimatedMinutes": mins,
        "exercises": exercises,
    }
    if desc:
        d["description"] = desc
    return d

V = {
    "lat": "https://www.youtube.com/watch?v=CAwf7n6Luuc",
    "row": "https://www.youtube.com/watch?v=GZbfZ033f74",
    "curl": "https://www.youtube.com/watch?v=soxrZlIl35U",
    "press": "https://www.youtube.com/watch?v=8iPEnn-ltC8",
    "fly": "https://www.youtube.com/watch?v=Iwe6EpLv6lM",
    "lat_raise": "https://www.youtube.com/watch?v=3VcKaXpzqRo",
    "leg_press": "https://www.youtube.com/watch?v=IZxyjW7MPJQ",
    "leg_ext": "https://www.youtube.com/watch?v=YyvSfVjQeL0",
    "calf": "https://www.youtube.com/watch?v=-M4-G8p8fmc",
    "deadlift": "https://www.youtube.com/watch?v=op9kVnSso6Q",
    "pullup": "https://www.youtube.com/watch?v=eGo4IYlbE5g",
    "dips": "https://www.youtube.com/watch?v=2z8JmcrW-As",
    "pushdown": "https://www.youtube.com/watch?v=2-LAMcpzODU",
    "bb_curl": "https://www.youtube.com/watch?v=kwG2ipFRgfo",
    "leg_curl": "https://www.youtube.com/watch?v=1Tq3QMpbTIg",
    "face_pull": "https://www.youtube.com/watch?v=rep-aKOiNTY",
    "skull": "https://www.youtube.com/watch?v=d_KjpgUtR6E",
}

w1d1 = day("w1d1", 1, "Lưng & Tay trước", "Lưng · Cơ nhị đầu", 75, [
    ex("ex_lat_pulldown", "Lat Pulldown", "Cơ lưng rộng", 4, "12/10", 120, drop=True, notes="12-12-10-10. Set cuối 1 lần drop set. 3 bài đầu max sức.", video=V["lat"]),
    ex("ex_wide_lat_pulldown", "Wide Grip Lat Pulldown", "Cơ lưng rộng", 4, "12/10", 120, drop=True, notes="12-12-10-10. Set cuối 2 lần drop set.", video=V["lat"]),
    ex("ex_cable_row_neutral", "Standing Cable Row (Neutral Grip)", "Lưng giữa", 4, "12/10", 120, drop=True, notes="12-12-10-10. Set cuối 3 lần drop set.", video=V["row"]),
    ex("ex_bent_over_row", "Bent Over Barbell Row", "Lưng", 3, "15", 90, fail=True, notes="15-15-15-fail. Tạ vừa, set cuối khô người."),
    ex("ex_incline_db_row", "Incline Dumbbell Row", "Lưng", 4, "15", 90, fail=True, notes="15-15-15-fail. Tạ vừa, set cuối khô người."),
    ex("ex_single_arm_lat_pulldown", "Single Arm Lat Pulldown (Neutral Grip)", "Cơ lưng rộng", 4, "20", 75, notes="Cầm tay bình thường, kéo xuống tay ngửa, giữ 2 giây.", video=V["lat"]),
    ex("ex_incline_db_curl", "Incline Dumbbell Curl", "Cơ nhị đầu", 4, "15/12", 60, notes="Ghế dốc 65°.", video=V["curl"]),
    ex("ex_preacher_curl", "Single Arm Dumbbell Preacher Curl", "Cơ nhị đầu", 4, "10-12", 60, notes="Ghế dốc 75°.", video=V["curl"]),
], "Buổi kéo — ưu tiên 3 bài đầu với tạ nặng nhất có thể.")

w1d2 = day("w1d2", 2, "Ngực & Vai", "Ngực · Vai", 70, [
    ex("ex_machine_incline_press", "Machine Incline Barbell Press", "Ngực trên", 4, "10/8", 120, drop=True, notes="10-10-8-8. Set cuối 2 lần drop set."),
    ex("ex_machine_chest_press", "Machine Chest Press", "Ngực", 4, "12/10", 120, drop=True, notes="12-12-10-10. Set cuối 2 lần drop set."),
    ex("ex_cable_fly", "Cable Fly", "Ngực", 4, "12-15", 75, notes="Bay ngang.", video=V["fly"]),
    ex("ex_standing_db_press", "Standing Dumbbell Shoulder Press", "Vai", 4, "12", 90, video=V["press"]),
    ex("ex_lateral_raise", "Dumbbell Lateral Raise", "Vai giữa", 4, "12-15", 60, drop=True, notes="Set cuối 3 lần drop set.", video=V["lat_raise"]),
    ex("ex_incline_db_fly", "Incline Dumbbell Fly", "Ngực trên", 3, "12-15", 75, notes="Ghế dốc tùy theo chân máy.", video=V["fly"]),
    ex("ex_incline_reverse_fly", "Incline Dumbbell Reverse Fly", "Vai sau", 4, "12", 60, notes="Ghế dốc tùy theo chân máy."),
    ex("ex_barbell_front_raise", "Barbell Front Raise", "Vai trước", 4, "15", 60, fail=True, notes="15-15-15-fail."),
])

w1d3 = day("w1d3", 3, "Chân", "Đùi trước · Đùi sau · Bắp chân", 85, [
    ex("ex_belt_squat", "Belt Squat Machine", "Đùi trước", 6, "12/8", 150, drop=True, notes="12-12-10-10-8-8. Set cuối 3 lần drop set."),
    ex("ex_leg_press", "Leg Press", "Đùi trước", 6, "12/10", 120, drop=True, notes="12-12-10-10-10-10. Set cuối 3 lần drop set.", video=V["leg_press"]),
    ex("ex_smith_squat", "Smith Squat", "Đùi trước", 6, "12/10", 120, drop=True, notes="12-12-12-10-10-10. Set cuối 3 lần drop set."),
    ex("ex_leg_extension", "Leg Extension", "Đùi trước", 4, "15", 60, video=V["leg_ext"]),
    ex("ex_standing_calf_raise", "Standing Calf Raise", "Bắp chân", 4, "12-15", 45, video=V["calf"]),
    ex("ex_seated_calf_raise", "Seated Calf Raise", "Bắp chân", 4, "10-12", 45),
], "Buổi chân nặng — chuẩn bị khô người.")

w1d4 = day("w1d4", 4, "Upper", "Ngực · Lưng · Cơ tay", 60, [
    ex("ex_machine_incline_press", "Machine Incline Barbell Press", "Ngực trên", 4, "10/8", 120, drop=True, notes="10-10-8-8. Set cuối 1 lần drop set."),
    ex("ex_dips", "Dips", "Ngực · Cơ ba đầu", 4, "fail", 90, fail=True, video=V["dips"]),
    ex("ex_machine_lateral_raise", "Machine Lateral Raise", "Vai giữa", 3, "15", 60),
    ex("ex_pullup", "Pull-Up", "Cơ lưng rộng", 4, "fail", 90, fail=True, video=V["pullup"]),
    ex("ex_machine_row", "Machine Row", "Lưng", 4, "15", 90, fail=True, notes="15-15-15-fail."),
    ex("ex_tricep_pushdown", "Triceps Pushdown", "Cơ ba đầu", 3, "fail", 60, fail=True, notes="Superset với Barbell Curl.", video=V["pushdown"]),
    ex("ex_barbell_curl", "Barbell Curl", "Cơ nhị đầu", 3, "fail", 60, fail=True, notes="Superset với Triceps Pushdown.", video=V["bb_curl"]),
], "Có thể đổi Upper/Lower lên đầu tuần.")

w1d5 = day("w1d5", 5, "Lower", "Đùi sau · Mông · Bắp chân", 65, [
    ex("ex_seated_leg_curl", "Seated Leg Curl", "Đùi sau", 6, "12", 90, drop=True, notes="Set cuối 1 lần drop set.", video=V["leg_curl"]),
    ex("ex_smith_lunge", "Smith Machine Lunge", "Mông · Đùi trước", 4, "fail", 90, fail=True),
    ex("ex_deadlift", "Deadlift", "Lưng · Đùi sau", 6, "12", 120, video=V["deadlift"]),
    ex("ex_one_leg_extension", "One Leg Extension", "Đùi trước", 4, "15", 60, notes="Gối hướng ra ngoài 45°, đá từng chân.", video=V["leg_ext"]),
    ex("ex_hip_abduction", "Hip Abduction", "Mông", 4, "fail", 60, fail=True),
    ex("ex_standing_calf_raise", "Standing Calf Raise", "Bắp chân", 4, "12-15", 45, video=V["calf"]),
])

w2d1 = day("w2d1", 1, "Vai", "Vai · Vai sau", 65, [
    ex("ex_lateral_raise", "Dumbbell Lateral Raise", "Vai giữa", 4, "12-15", 60, drop=True, notes="Set cuối 3 lần drop set.", video=V["lat_raise"]),
    ex("ex_seated_db_press", "Seated Dumbbell Shoulder Press", "Vai", 4, "12/8", 90, notes="12, 10, 8, 12 reps."),
    ex("ex_standing_bb_machine_press", "Standing Barbell Machine Press", "Vai", 4, "10-12", 90, drop=True, notes="Set cuối 3 lần drop set."),
    ex("ex_upright_row", "Barbell Upright Row", "Vai", 4, "10-12", 75),
    ex("ex_y_raise", "High Incline Dumbbell Y Raise", "Vai sau", 3, "12-15", 60),
    ex("ex_db_reverse_fly", "Dumbbell Reverse Fly", "Vai sau", 4, "12-15", 60),
    ex("ex_db_shrugs", "Dumbbell Shrugs", "Cơ thang", 3, "12", 60, notes="Superset với Rope Face Pulls."),
    ex("ex_face_pull", "Rope Face Pull", "Vai sau", 3, "12", 60, notes="Superset với Dumbbell Shrugs.", video=V["face_pull"]),
])

w2d2 = day("w2d2", 2, "Lưng", "Lưng · Cơ lưng rộng", 75, [
    ex("ex_neutral_lat_pulldown", "Neutral Grip Lat Pulldown", "Cơ lưng rộng", 6, "10-12", 120, drop=True, notes="Set cuối 3 lần drop set.", video=V["lat"]),
    ex("ex_chest_supported_row", "Chest Supported Row", "Lưng", 4, "10-12", 90, drop=True, notes="Set cuối 1 lần drop set."),
    ex("ex_wide_lat_pulldown", "Wide Grip Lat Pulldown", "Cơ lưng rộng", 6, "10-12", 120, drop=True, notes="Set cuối 3 lần drop set.", video=V["lat"]),
    ex("ex_single_arm_cable_pulldown", "Single Arm Cable Pulldown", "Cơ lưng rộng", 6, "10-12", 75, video=V["lat"]),
    ex("ex_wide_seated_cable_row", "Wide Grip Seated Cable Row", "Lưng", 4, "10-12", 90, video=V["row"]),
    ex("ex_hanging_pullup", "Hanging Pull-Up Hold", "Cơ lưng rộng", 3, "60s", 90, notes="Treo không kéo lên, giữ 60 giây.", video=V["pullup"]),
])

w2d3 = day("w2d3", 3, "Chân", "Đùi trước · Đùi sau · Bắp chân", 75, [
    ex("ex_leg_extension", "Leg Extension", "Đùi trước", 5, "12-15", 75, drop=True, notes="Set cuối 3 lần drop set.", video=V["leg_ext"]),
    ex("ex_db_lunge", "Dumbbell Lunge", "Mông · Đùi trước", 4, "8-10", 90, drop=True, notes="Set cuối 1 lần drop set. Không tạ, mỗi chân 20 bước."),
    ex("ex_leg_press", "Leg Press", "Đùi trước", 6, "10-12", 120, drop=True, notes="Set cuối 3 lần drop set.", video=V["leg_press"]),
    ex("ex_belt_squat", "Belt Squat", "Đùi trước", 4, "12/8", 120, drop=True, notes="12-10-10-8. Set cuối 3 lần drop set."),
    ex("ex_seated_leg_curl", "Seated Leg Curl", "Đùi sau", 4, "12-15", 75, drop=True, notes="Set cuối 2 lần drop set.", video=V["leg_curl"]),
    ex("ex_standing_calf_raise", "Standing Calf Raise", "Bắp chân", 4, "10-12", 45, video=V["calf"]),
])

w2d4 = day("w2d4", 4, "Upper", "Ngực · Vai · Cơ tay", 70, [
    ex("ex_smith_incline_press", "Slight Incline Smith Machine Press", "Ngực trên", 4, "10/8", 120, drop=True, notes="Ghế dốc 30°. 10,10,8,8. Set cuối 2 lần drop set."),
    ex("ex_incline_db_press", "Incline Dumbbell Press", "Ngực trên", 4, "10-12", 90, notes="Ghế dốc 30°.", video=V["press"]),
    ex("ex_flat_machine_press", "Flat Machine Press", "Ngực", 4, "10-12", 90, drop=True, notes="Set cuối 1 lần drop set."),
    ex("ex_low_high_cable_fly", "Seated Low To High Cable Fly", "Ngực trên", 4, "10-12", 75, video=V["fly"]),
    ex("ex_machine_front_raise", "Machine Front Raise", "Vai trước", 3, "15", 60, notes="Superset từng tay với Machine Lateral Raise. Set cuối 3 lần drop set."),
    ex("ex_machine_lateral_raise", "Machine Lateral Raise", "Vai giữa", 3, "15", 60, notes="Superset từng tay với Machine Front Raise."),
    ex("ex_machine_shoulder_press", "Machine Shoulder Press", "Vai", 4, "10-12", 90),
    ex("ex_rope_hammer_curl", "Rope Hammer Curl", "Cơ nhị đầu", 4, "10-12", 60, notes="Superset với V-Bar Cable Pushdown."),
    ex("ex_vbar_pushdown", "V-Bar Cable Pushdown", "Cơ ba đầu", 4, "10-12", 60, notes="Superset với Rope Hammer Curl.", video=V["pushdown"]),
])

w2d5 = day("w2d5", 5, "Lower", "Đùi sau · Mông · Bắp chân", 65, [
    ex("ex_seated_leg_curl", "Seated Leg Curl", "Đùi sau", 6, "12", 90, drop=True, notes="Set cuối 1 lần drop set.", video=V["leg_curl"]),
    ex("ex_smith_lunge", "Smith Machine Lunge", "Mông · Đùi trước", 4, "fail", 90, fail=True),
    ex("ex_deadlift", "Deadlift", "Lưng · Đùi sau", 6, "12", 120, video=V["deadlift"]),
    ex("ex_one_leg_extension", "One Leg Extension", "Đùi trước", 4, "15", 60, notes="Gối hướng ra ngoài 45°, đá từng chân.", video=V["leg_ext"]),
    ex("ex_hip_abduction", "Hip Abduction", "Mông", 4, "fail", 60, fail=True),
    ex("ex_standing_calf_raise", "Standing Calf Raise", "Bắp chân", 4, "12-15", 45, video=V["calf"]),
], "Lower lần 2 — giữ nguyên cấu trúc tuần 1.")

w3d1 = day("w3d1", 1, "Tay", "Cơ nhị đầu · Cơ ba đầu", 60, [
    ex("ex_barbell_curl", "Barbell Curl", "Cơ nhị đầu", 4, "10-12", 60, drop=True, notes="Superset với Rope Pushdown. Drop set 1 lần cả 2 bài.", video=V["bb_curl"]),
    ex("ex_rope_pushdown", "Rope Triceps Pushdown", "Cơ ba đầu", 4, "12-15", 60, drop=True, notes="Superset với Barbell Curl.", video=V["pushdown"]),
    ex("ex_incline_db_curl", "Incline Dumbbell Curl", "Cơ nhị đầu", 4, "10-12", 60, drop=True, notes="Superset với Seated Cable Overhead Tricep Extension.", video=V["curl"]),
    ex("ex_oh_tricep_ext", "Seated Cable Overhead Tricep Extension", "Cơ ba đầu", 4, "10-12", 60, drop=True, notes="Superset với Incline Dumbbell Curl."),
    ex("ex_dips", "Dips", "Cơ ba đầu", 4, "10-12", 75, notes="Superset với Slight Incline EZ Bar Skull Crusher.", video=V["dips"]),
    ex("ex_skull_crusher", "Slight Incline EZ Bar Skull Crusher", "Cơ ba đầu", 4, "10-12", 75, notes="Superset với Dips.", video=V["skull"]),
    ex("ex_alt_hammer_curl", "Alternating Dumbbell Hammer Curl", "Cơ nhị đầu", 4, "10-12", 60, drop=True, notes="Superset với Single Arm Across Body Tricep Extension."),
    ex("ex_across_body_tricep", "Single Arm Across Body Tricep Extension", "Cơ ba đầu", 4, "10-12", 60, drop=True, notes="Superset với Alternating Hammer Curl."),
])

w3d2 = day("w3d2", 2, "Chân", "Đùi trước · Đùi sau · Bắp chân", 70, [
    ex("ex_seated_leg_curl", "Seated Leg Curl", "Đùi sau", 4, "12-15", 75, drop=True, notes="Superset với Good Morning. Set cuối 3 lần drop set.", video=V["leg_curl"]),
    ex("ex_good_morning", "Good Morning", "Đùi sau · Lưng", 4, "fail", 90, fail=True, notes="Superset với Seated Leg Curl. Set cuối >40 reps."),
    ex("ex_smith_squat", "Smith Machine Squat", "Đùi trước", 4, "10-12", 120, drop=True, notes="Set cuối 1 lần drop set + lunges không tạ đến fail."),
    ex("ex_leg_press", "Leg Press", "Đùi trước", 4, "10", 120, drop=True, notes="Set cuối 2 lần drop set.", video=V["leg_press"]),
    ex("ex_leg_extension", "Leg Extension", "Đùi trước", 4, "18", 75, drop=True, notes="Set 3 giữ trên 5s/rep. Set cuối drop set + lunges không tạ.", video=V["leg_ext"]),
    ex("ex_standing_calf_raise", "Standing Calf Raise", "Bắp chân", 4, "20", 45, video=V["calf"]),
])

w3d3 = day("w3d3", 3, "Lưng", "Lưng · Cơ lưng rộng", 70, [
    ex("ex_close_grip_lat_pulldown", "Close Grip Lat Pulldown", "Cơ lưng rộng", 4, "10-12", 120, drop=True, notes="Set cuối 3 lần drop set.", video=V["lat"]),
    ex("ex_underhand_cable_pulldown", "High Incline Cable Pulldown (Underhand Grip)", "Cơ lưng rộng", 4, "10-12", 90, drop=True, notes="Set cuối 2 lần drop set."),
    ex("ex_machine_row", "Machine Row", "Lưng", 4, "10-12", 90, drop=True, notes="Set cuối 3 lần drop set."),
    ex("ex_wide_lat_pulldown", "Wide Grip Lat Pulldown", "Cơ lưng rộng", 4, "10-12", 90, drop=True, notes="Set cuối 3 lần drop set.", video=V["lat"]),
    ex("ex_chest_supported_db_row", "Chest Supported Dumbbell Row", "Lưng", 4, "10-12", 90, drop=True, notes="Set cuối 2 lần drop set."),
    ex("ex_low_machine_row", "Low Machine Row (Straight Grip)", "Lưng", 4, "10-12", 90, drop=True, notes="Set cuối 2 lần drop set."),
])

w3d4 = day("w3d4", 4, "Push", "Ngực · Vai · Cơ ba đầu", 75, [
    ex("ex_machine_fly", "Machine Fly", "Ngực", 4, "12-15", 75, drop=True, notes="Set cuối 2 lần drop set."),
    ex("ex_smith_incline_press", "Smith Machine Incline Press", "Ngực trên", 4, "8/10", 120, drop=True, notes="2 hiệp đầu ghế 45°, 2 hiệp sau 30°. Set cuối 2 lần drop set."),
    ex("ex_db_shoulder_press", "Dumbbell Shoulder Press", "Vai", 4, "10-12", 90, drop=True, notes="Set cuối 1 lần drop set."),
    ex("ex_lateral_raise", "Dumbbell Lateral Raise", "Vai giữa", 4, "12-15", 60, drop=True, notes="Set cuối 1 lần drop set.", video=V["lat_raise"]),
    ex("ex_flat_machine_press", "Flat Machine Press", "Ngực", 4, "10-12", 90, drop=True, notes="Set cuối 1 lần drop set."),
    ex("ex_one_arm_cable_lateral", "One Arm Cable Lateral Raise", "Vai giữa", 3, "25", 45),
    ex("ex_tricep_pushdown", "Cable Tricep Pushdown", "Cơ ba đầu", 4, "12-15", 60, video=V["pushdown"]),
    ex("ex_dips", "Dips", "Cơ ba đầu", 4, "fail", 75, fail=True, notes="Superset với Rope Overhead Extension.", video=V["dips"]),
    ex("ex_rope_oh_extension", "Rope Overhead Tricep Extension", "Cơ ba đầu", 4, "12-15", 75, notes="Superset với Dips."),
])

w3d5 = day("w3d5", 5, "Lower", "Đùi sau · Mông · Bắp chân", 65, [
    ex("ex_seated_leg_curl", "Seated Leg Curl", "Đùi sau", 6, "12", 90, drop=True, notes="Set cuối 1 lần drop set.", video=V["leg_curl"]),
    ex("ex_smith_lunge", "Smith Machine Lunge", "Mông · Đùi trước", 4, "fail", 90, fail=True),
    ex("ex_deadlift", "Deadlift", "Lưng · Đùi sau", 6, "12", 120, video=V["deadlift"]),
    ex("ex_one_leg_extension", "One Leg Extension", "Đùi trước", 4, "15", 60, notes="Gối hướng ra ngoài 45°, đá từng chân.", video=V["leg_ext"]),
    ex("ex_hip_abduction", "Hip Abduction", "Mông", 4, "fail", 60, fail=True),
    ex("ex_standing_calf_raise", "Standing Calf Raise", "Bắp chân", 4, "12-15", 45, video=V["calf"]),
], "Lower lần 3 — giữ nguyên cấu trúc.")

program = {
    "id": "personal_ppl_v2",
    "name": "Lịch PPL + Upper/Lower",
    "description": "Chương trình 3 tuần theo lịch HLV: Tuần 1 PPL, Tuần 2 Vai/Lưng, Tuần 3 Tay/Push. 5 buổi/tuần (nghỉ 1 ngày giữa tuần). Có thể đổi Upper/Lower lên đầu tuần rồi nghỉ 1 ngày, tập tiếp 3 ngày PPL.",
    "author": "HLV",
    "version": "2.0",
    "weeks": [
        {"weekNumber": 1, "title": "Lịch 1 — PPL", "focus": "Push Pull Leg + Upper/Lower. 3 bài kéo đầu buổi lưng: max sức. Buổi chân: volume cao, nhiều drop set.", "days": [w1d1, w1d2, w1d3, w1d4, w1d5]},
        {"weekNumber": 2, "title": "Lịch 2 — Vai/Lưng", "focus": "Tập trung vai và lưng với volume cao. Lower giữ nguyên như tuần 1.", "days": [w2d1, w2d2, w2d3, w2d4, w2d5]},
        {"weekNumber": 3, "title": "Lịch 3 — Tay/Push", "focus": "Buổi tay toàn supersets. Chân và lưng volume cao. Push kết hợp ngực-vai-tay sau.", "days": [w3d1, w3d2, w3d3, w3d4, w3d5]},
    ],
}

out = Path(__file__).resolve().parents[1] / "assets" / "data" / "workout_program.json"
out.write_text(json.dumps(program, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
total_days = sum(len(w["days"]) for w in program["weeks"])
total_ex = sum(len(d["exercises"]) for w in program["weeks"] for d in w["days"])
print(f"Wrote {out}")
print(f"{len(program['weeks'])} weeks, {total_days} days, {total_ex} exercises")
