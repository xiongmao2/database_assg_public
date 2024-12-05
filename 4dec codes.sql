DROP DATABASE IF EXISTS cullinary_studio;
CREATE DATABASE cullinary_studio;
USE cullinary_studio;

CREATE TABLE client (
    client_id INT NOT NULL PRIMARY KEY,
    client_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15),       
    email VARCHAR(50),
    birthdate DATE
);
              
CREATE TABLE client_feedback (
    feedback_id INT NOT NULL PRIMARY KEY,
    client_id INT,
    rating INT NOT NULL,
    review VARCHAR(1000),
    FOREIGN KEY (client_id) REFERENCES client(client_ID) 
);

CREATE TABLE chef (
	chef_id INT NOT NULL PRIMARY KEY,
    name VARCHAR(100), 
    phone_number VARCHAR(15),
    email VARCHAR(50),
    specialization VARCHAR(50));
    


CREATE TABLE certification (
    cert_id INT NOT NULL AUTO_INCREMENT, -- Unique certification ID
    chef_id INT NOT NULL, -- Chef's ID
    cert_name VARCHAR(100) NOT NULL, -- Certification Name
    cert_date DATE, -- Certification Date
    PRIMARY KEY (cert_id),
    UNIQUE (chef_id, cert_name), -- Ensures each chef has a unique certification name
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id)
);

    


CREATE TABLE class (
	class_id INT NOT NULL PRIMARY KEY,
	name VARCHAR(100),
	date DATE,
	start_time TIME,
	end_time TIME,
	class_type VARCHAR(30) CHECK (class_type IN ('seminar','workshop','private_session' )),
    chef_id INT,
    FOREIGN KEY (chef_id) REFERENCES chef(chef_id));
    
CREATE TABLE attendance (
    attendance_id INT NOT NULL,
    class_id INT NOT NULL,
    class_type VARCHAR(20) NOT NULL, -- Keep this as a regular column
    client_id INT NOT NULL,
    PRIMARY KEY (attendance_id),
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id)
);


DELIMITER $$

CREATE TRIGGER validate_class_type
BEFORE INSERT ON attendance
FOR EACH ROW
BEGIN
    -- Check if the class_type matches the class_id
    IF NOT EXISTS (
        SELECT 1
        FROM class
        WHERE class_id = NEW.class_id AND class_type = NEW.class_type
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Class type does not match the class ID.';
    END IF;
END$$

DELIMITER ;

    
DELIMITER $$

CREATE TRIGGER validate_private_session
BEFORE INSERT ON class
FOR EACH ROW
BEGIN
    -- Check if the class_type is 'private_session'
    IF NEW.class_type = 'private_session' THEN
        -- Ensure the chef has a specialization
        IF NOT EXISTS (
            SELECT 1
            FROM chef
            WHERE chef_id = NEW.chef_id AND specialization IS NOT NULL
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Only chefs with a specialization can teach private sessions';
        END IF;
    END IF;
END$$

DELIMITER ;



CREATE TABLE seminar (
    class_id INT NOT NULL, 
    PRIMARY KEY (class_id), 
    FOREIGN KEY (class_id) REFERENCES class(class_id) ,
    activity_type VARCHAR(100) 
    CHECK (activity_type IN 
    ('cooking demonstrations', 'ingredient testing', 'recipes analysis', 'cullinary education',
    'skills', 'food presentation', 'sustainability in cooking', 'health and nutrition talk', 
    'flavour pairing talk'))
);

CREATE TABLE workshop (
	class_id INT NOT NULL,
    PRIMARY KEY (class_id), 
    FOREIGN KEY (class_id) REFERENCES class(class_id) ,
    workshop_type VARCHAR(100)
    CHECK (workshop_type IN
    ('baking', 'italian cuisine', 'sushi making', 'indian cuisine', 'chinese cuisine', 'malay cuisine')),
    difficulty_level VARCHAR(10) CHECK (difficulty_level IN
    ('easy','medium','hard'))
    );
    
CREATE TABLE private_session (
	class_id INT NOT NULL,
    PRIMARY KEY (class_id), 
    FOREIGN KEY (class_id) REFERENCES class(class_id) ,
    client_special_request VARCHAR(100)
    );


    
CREATE TABLE advertainment (
	advertainment_id INT NOT NULL PRIMARY KEY,
    platform VARCHAR(50));
    
CREATE TABLE seminar_advertainment_relationship (
	class_id INT NOT NULL,
    advertainment_id INT NOT NULL,
    FOREIGN KEY (class_id) REFERENCES seminar(class_id),
    FOREIGN KEY (advertainment_id) REFERENCES advertainment(advertainment_id));
	
    
CREATE TABLE equipment (
	equipment_ID INT NOT NULL,
    equipment_name VARCHAR(50) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (equipment_id));
    
CREATE TABLE renting (
	renting_id INT NOT NULL,
	start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    client_id INT NOT NULL,
    equipment_id INT NOT NULL,
    PRIMARY KEY (renting_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id));
    
CREATE TABLE membership (
	member_id INT NOT NULL,
    loyalty_points INT NOT NULL,
    client_id INT NOT NULL,
    exclusive_chef VARCHAR(3) CHECK (exclusive_chef IN ('yes','no')) NOT NULL,
    PRIMARY KEY (member_id),
    FOREIGN KEY (client_id) REFERENCES client(client_id)
    );
    


CREATE TABLE chef_meet_n_greet (
	cmg_id INT NOT NULL,
    date DATE,
    start_time TIME,
    end_time TIME,
    chef_id INT NOT NULL,
    PRIMARY KEY (cmg_id));
    
CREATE TABLE chef_meet_n_greet_participants (
	cmg_id INT NOT NULL,
    participant_id INT NOT NULL, 
	PRIMARY KEY (cmg_id , participant_id),
    FOREIGN KEY (participant_id) REFERENCES membership(member_id),
    FOREIGN KEY (cmg_id) REFERENCES chef_meet_n_greet (cmg_id)
    );

DELIMITER $$

CREATE TRIGGER validate_exclusive_chef_participation
BEFORE INSERT ON chef_meet_n_greet_participants
FOR EACH ROW
BEGIN
    -- Check if the participant is eligible to participate (i.e., has 'yes' under exclusive_chef)
    IF NOT EXISTS (
        SELECT 1
        FROM membership
        WHERE member_id = NEW.participant_id AND exclusive_chef = 'yes'
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only members with exclusive_chef = ''yes'' can participate in Chef Meet and Greet';
    END IF;
END$$

DELIMITER ;

    
CREATE TABLE group_membership (
	group_id INT NOT NULL,
    holder_id INT,
    no_of_pax INT,
    PRIMARY KEY (group_id),
    FOREIGN KEY (holder_id) REFERENCES membership(member_id));
    
CREATE TABLE group_info (
	group_id INT,
    client_id INT,
    PRIMARY KEY (group_id, client_id)
    );

CREATE TABLE challenge (
	challenge_id INT NOT NULL,
    challenge_name VARCHAR(100),
    PRIMARY KEY (challenge_id)
    );
    
CREATE TABLE badge (
	badges_id INT NOT NULL,
    member_id INT NOT NULL, 
    challenge_id INT NOT NULL,
    PRIMARY KEY (badges_id),
    FOREIGN KEY (member_id) REFERENCES membership(member_id),
    FOREIGN KEY (challenge_id) REFERENCES challenge(challenge_id));
    




INSERT INTO client VALUES 
(1001, 'Alex', '6013-2753621', 'alex253@gmail.com', '2004-01-05'),
(1002, 'Melissa', '6018-8835139', 'melissa709@gmail.com', '1996-02-23'),
(1003, 'Paul', '6013-3247853', 'paul230@gmail.com', '1997-05-30'),
(1004, 'Jacob', '6018-0694214', 'jacob856@gmail.com', '2005-09-05'),
(1005, 'Brett', '6011-5230969', 'brett366@gmail.com', '2005-09-11'),
(1006, 'Kayla', '6018-3570090', 'kayla629@gmail.com', '2001-05-16');


INSERT INTO client_feedback VALUES
(2001, 1001, 3, 'I enjoyed this workshop a lot.'),
(2002, 1001, 4, 'I benefited from the pastry workshop, and made some new friends.'),
(2003, 1002, 2, 'The chef is not as good as expected.');

INSERT INTO chef (chef_id, name, phone_number, email, specialization) VALUES
(4001, 'Peter', '6012-5736360', 'chefpeter32@gmail.com', 'Pastry'),
(4002, 'Sarah', '6018-2480021', 'sarahdough54@gmail.com', 'Italian Cuisine'),
(4003, 'James', '6011-8825379', 'chefjames72@gmail.com', 'Sushi'),
(4004, 'Michele', '6013-3451253', 'michele_bakes@gmail.com', 'Bakery'),
(4005, 'Linda', '6012-1115372', 'chef.linda32@gmail.com', 'Healthy Meals'),
(4006, 'Andrew', '6013-6769002', 'andrew_thechef@gmail.com', 'Fusion Cuisine'),
(4007, 'David', '6018-5437871', 'davidmeals@gmail.com', 'Fine Dining'),
(4008, 'Sophia', '6012-4932011', 'sophia.sushi@gmail.com', 'Japanese Cuisine'),
(4009, 'Tom', '6011-6745913', 'chef_tom@gmail.com', 'Chinese Cuisine'),
(4010, 'Ella', '6018-8902224', 'chefella@gmail.com', 'Vegan Cooking');

INSERT INTO certification (cert_id, chef_id, cert_name, cert_date) VALUES
(3001, 4001, 'Pastry Masterclass', '2022-01-10'),
(3002, 4002, 'Italian Cuisine Certification', '2023-03-15'),
(3003, 4003, 'Sushi Advanced Training', '2023-05-20'),
(3004, 4004, 'Bakery Essentials', '2022-11-12'),
(3005, 4005, 'Healthy Meal Prep', '2023-01-25'),
(3006, 4006, 'Fusion Cooking Expert', '2023-04-10'),
(3007, 4007, 'Fine Dining Etiquette', '2022-06-14'),
(3008, 4008, 'Japanese Cuisine Specialist', '2023-07-07'),
(3009, 4009, 'Chinese Cuisine Innovator', '2023-02-18'),
(3010, 4010, 'Vegan Cooking Pro', '2022-09-01');

INSERT INTO class (class_id, name, date, start_time, end_time, class_type, chef_id) VALUES
(5001, 'Pastry Workshop', '2024-01-15', '10:00:00', '12:00:00', 'workshop', 4001),
(5002, 'Italian Cuisine Seminar', '2024-02-10', '14:00:00', '16:00:00', 'seminar', 4002),
(5003, 'Sushi Private Session', '2024-03-12', '18:00:00', '20:00:00', 'private_session', 4003),
(5004, 'Bakery Workshop', '2024-04-05', '09:00:00', '11:00:00', 'workshop', 4004),
(5005, 'Healthy Meals Seminar', '2024-05-20', '13:00:00', '15:00:00', 'seminar', 4005),
(5006, 'Fusion Cuisine Private Session', '2024-06-25', '17:00:00', '19:00:00', 'private_session', 4006),
(5007, 'Fine Dining Seminar', '2024-07-18', '12:00:00', '14:00:00', 'seminar', 4007),
(5008, 'Japanese Cuisine Workshop', '2024-08-02', '16:00:00', '18:00:00', 'workshop', 4008),
(5009, 'Chinese Cuisine Private Session', '2024-09-10', '19:00:00', '21:00:00', 'private_session', 4009),
(5010, 'Vegan Cooking Seminar', '2024-10-01', '11:00:00', '13:00:00', 'seminar', 4010);

INSERT INTO seminar (class_id, activity_type) VALUES
(5002, 'cooking demonstrations'),
(5005, 'ingredient testing'),
(5007, 'recipes analysis');

INSERT INTO workshop (class_id, workshop_type, difficulty_level) VALUES
(5001, 'baking', 'medium'),
(5004, 'italian cuisine', 'hard'),
(5008, 'sushi making', 'easy');

INSERT INTO private_session (class_id, client_special_request) VALUES
(5003, 'special request for vegetarian sushi'),
(5006, 'request for custom fusion dishes'),
(5009, 'client interested in learning authentic Chinese stir fry');

INSERT INTO attendance (attendance_id, class_id, class_type, client_id) VALUES
(6001, 5001, 'workshop', 1001),
(6002, 5002, 'seminar', 1002),
(6003, 5003, 'private_session', 1003),
(6004, 5004, 'workshop', 1004),
(6005, 5005, 'seminar', 1005),
(6006, 5006, 'private_session', 1006),
(6007, 5007, 'seminar', 1001),
(6008, 5008, 'workshop', 1002),
(6009, 5009, 'private_session', 1003),
(6010, 5010, 'seminar', 1004);

INSERT INTO advertainment (advertainment_id, platform) VALUES
(7001, 'Facebook'),
(7002, 'Instagram'),
(7003, 'YouTube'),
(7004, 'Twitter'),
(7005, 'LinkedIn'),
(7006, 'Google Ads'),
(7007, 'TikTok'),
(7008, 'Pinterest'),
(7009, 'Snapchat'),
(7010, 'Email Marketing');

INSERT INTO equipment (equipment_id, equipment_name, quantity) VALUES
(8001, 'Oven', 5),
(8002, 'Mixer', 10),
(8003, 'Knives', 20),
(8004, 'Cooking Pot', 15),
(8005, 'Rolling Pin', 12),
(8006, 'Measuring Cups', 25),
(8007, 'Cutting Board', 30),
(8008, 'Spatula', 40),
(8009, 'Whisk', 50),
(8010, 'Baking Tray', 10);

INSERT INTO membership (member_id, loyalty_points, client_id, exclusive_chef) VALUES
(9001, 150, 1001, 'yes'),
(9002, 200, 1002, 'yes'),
(9003, 300, 1003, 'no'),
(9004, 400, 1004, 'yes'),
(9005, 500, 1005, 'no'),
(9006, 250, 1006, 'yes'),
(9007, 100, 1001, 'no'),
(9008, 50, 1002, 'no'),
(9009, 120, 1003, 'yes'),
(9010, 400, 1004, 'yes');







INSERT INTO seminar_advertainment_relationship (class_id, advertainment_id) VALUES
(5002, 7002),
(5002, 7003),
(5002, 7005),
(5005, 7003),
(5005, 7004),
(5005, 7006),
(5007, 7004),
(5007, 7006),
(5007, 7008),
(5007, 7010);




INSERT INTO renting (renting_id, start_date, end_date, client_id, equipment_id) VALUES
(10001, '2024-01-10', '2024-01-15', 1001, 8001),
(10002, '2024-02-05', '2024-02-10', 1002, 8002),
(10003, '2024-03-01', '2024-03-07', 1003, 8003),
(10004, '2024-04-12', '2024-04-18', 1004, 8004),
(10005, '2024-05-03', '2024-05-08', 1005, 8005),
(10006, '2024-06-07', '2024-06-14', 1006, 8006),
(10007, '2024-07-20', '2024-07-25', 1001, 8007),
(10008, '2024-08-13', '2024-08-18', 1002, 8008),
(10009, '2024-09-04', '2024-09-10', 1003, 8009),
(10010, '2024-10-01', '2024-10-07', 1004, 8010);

INSERT INTO chef_meet_n_greet (cmg_id, date, start_time, end_time, chef_id) VALUES
(20001, '2024-01-20', '10:00:00', '12:00:00', 4001),
(20002, '2024-02-15', '14:00:00', '16:00:00', 4002),
(20003, '2024-03-10', '18:00:00', '20:00:00', 4003),
(20004, '2024-04-25', '11:00:00', '13:00:00', 4004),
(20005, '2024-05-18', '09:00:00', '11:00:00', 4005),
(20006, '2024-06-23', '17:00:00', '19:00:00', 4006),
(20007, '2024-07-30', '12:00:00', '14:00:00', 4007),
(20008, '2024-08-22', '15:00:00', '17:00:00', 4008),
(20009, '2024-09-14', '10:00:00', '12:00:00', 4009),
(20010, '2024-10-05', '13:00:00', '15:00:00', 4010);

INSERT INTO chef_meet_n_greet_participants (cmg_id, participant_id) VALUES
(20001, 9010),
(20002, 9009),
(20003, 9006),
(20004, 9009),
(20005, 9010),
(20006, 9006),
(20007, 9009),
(20008, 9010),
(20009, 9006),
(20010, 9010);


INSERT INTO group_membership (group_id, holder_id, no_of_pax) VALUES
(30001, 9001, 4),
(30002, 9002, 3),
(30003, 9003, 6),
(30004, 9004, 5),
(30005, 9005, 7),
(30006, 9006, 2),
(30007, 9007, 8),
(30008, 9008, 4),
(30009, 9009, 3),
(30010, 9010, 9);

INSERT INTO group_info (group_id, client_id) VALUES
(30001, 1001),
(30002, 1002),
(30003, 1003),
(30004, 1004),
(30005, 1005),
(30006, 1006),
(30007, 1001),
(30008, 1002),
(30009, 1003),
(30010, 1004);

INSERT INTO challenge (challenge_id, challenge_name) VALUES
(11001, 'Best Dessert'),
(11002, 'Creative Sushi'),
(11003, 'Perfect Pasta'),
(11004, 'Artistic Plating'),
(11005, 'Healthy Cooking Challenge'),
(11006, 'Fusion Fiesta'),
(11007, 'Fine Dining Skills'),
(11008, 'Ingredient Mastery'),
(11009, 'Food Presentation Pro'),
(11010, 'Baking Excellence');

INSERT INTO badge (badges_id, member_id, challenge_id) VALUES
(12001, 9001, 11001),
(12002, 9002, 11002),
(12003, 9003, 11003),
(12004, 9004, 11004),
(12005, 9005, 11005),
(12006, 9006, 11006),
(12007, 9007, 11007),
(12008, 9008, 11008),
(12009, 9009, 11009),
(12010, 9010, 11010);

SELECT * from  client ;
SELECT * from  client_feedback ;
SELECT * from   class;
SELECT * from   chef;
SELECT * from   attendance;
SELECT * from   certification;
SELECT * from   membership;
SELECT * from   renting;
SELECT * from   equipment;
SELECT * from   challenge;
SELECT * from   badge;
SELECT * from   seminar;
SELECT * from   seminar_advertainment_relationship;
SELECT * from   workshop;
SELECT * from   private_session;
SELECT * from   advertainment;
SELECT * from   chef_meet_n_greet participants;
SELECT * from   chef_meet_n_greet;
SELECT * from   group_membership;
SELECT * from   group_info;





