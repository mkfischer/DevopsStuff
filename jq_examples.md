# **JQ examples**

### Display colored results:

`aws ec2 describe-instances | jq `

### Display only the N element in array:

`aws ec2 describe-instances | jq '.Reservations[]?.Instances | .[0]'`

### Drill down into the JSON:

`aws ec2 describe-instances | jq '.Reservations[].Instances[].InstanceType'`

### Drill down into JSON, display output in raw mode:

`aws ec2 describe-instances | jq -r '.Reservations[].Instances[].InstanceType'`

### Display all the Values of a Key:

`aws ec2 describe-instances | jq '.Reservations[]?.Instances[].NetworkInterfaces[].PrivateIpAddresses[] | .[]'`

### Display all the Values where the Key contains "DOCKERVERSION":

`aws ec2 describe-instances | jq -r '.Reservations[].Instances[].Tags[] | select(.Key | contains("DOCKERVERSION")).Value'`

### Display all the Values where the Key eqauls "Name":

`aws ec2 describe-vpcs --region us-east-1 | jq -r '.Vpcs[].Tags[] | select(.Key=="Name") | .Value'`

### Searching for a Name where the value starts with "staging":

`aws route53 list-resource-record-sets --hosted-zone-id $zoneId | jq -r '.ResourceRecordSets[]? | select(.ResourceRecords[]?.Value | startswith("staging")) | .Name'`

### Supplying a variable to jq:

`jq --arg varName varValue ''`

### Supplying a variable to jq as the search pattern:

`aws route53 list-resource-record-sets --hosted-zone-id $zoneId | jq -r --arg pattern $newStgRenderer '.ResourceRecordSets[]? | select(.ResourceRecords[]?.Value | contains($pattern)) | .Name'`

### Map an object to arrays:

`aws ec2 describe-instances | jq -r '.Reservations[].Instances[].SecurityGroups[] | to_entries[] | [.key, .value]'`

Example output:
> [
>   "GroupName",
>   "ALLOW-SSH-FROM-OFFICE"
> ]
> [
>   "GroupId",
>   "sg-f24XXX88"
> ]

### Transforming jq output:

`aws ec2 describe-instances | jq ".Reservations[].Instances[] | { VpcId: .VpcId , SubnetId: .SubnetId}"`

Example output:
> {
>   "VpcId": "vpc-de5xxx9",
>   "SubnetId": "subnet-c11165ef"
> }
> {
>   "VpcId": "vpc-de5xxx9",
>   "SubnetId": "subnet-111bce3f"
> }

### Transform using specific element in array (in this case, the first one):

`jq '.[0] | { Author: .author.login, Url: .committer.url}'`

Example output:
> curl -s 'https://api.github.com/repos/geek-kb/DevopsStuff/commits?per_page=5' | jq '.[0] | { Author: .author.login, Url: .committer.url}'
> {
>   "Author": "geek-kb",
>   "Url": "https://api.github.com/users/geek-kb"
> }

<br><br>

#**Troubleshooting:**

### Sometimes, when not all elements have keys, the following error will be shown:

`jq: error (at <stdin>:52243): Cannot iterate over null (null)`
<br><br>
Example:
<br><br>
`aws ec2 describe-instances | jq ".Reservations[].Instances[] | {VirtualizationType: .VirtualizationType , Tags: .Tags[]}" | tail -5`
> jq: error (at <stdin>:52243): Cannot iterate over null (null)
>   "Tags": {
>     "Key": "SWARM_TYPE",
>     "Value": "Production"
>   }
> }

In order to supress this error, add a question mark after the key which doesn't exist in all elements, in this case "Tags".
<br><br>
Example:
<br><br>
`aws ec2 describe-instances | jq ".Reservations[].Instances[] | {VirtualizationType: .VirtualizationType , Tags: .Tags[]?}" | tail -5`

>   "Tags": {
>     "Key": "SWARM_TYPE",
>     "Value": "Production"
>   }
> }


<br><br>


Written by: Itai Ganot, lel@lel.bz
