# Show all users in the system
function allusers
  cut -d: -f1 /ect/passwd
end
