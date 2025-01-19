require("math")
lastTag = 0
Tick = 0
channels = 4
bAwait = true

actionStatus = {
	aGain = {},
	aMute = {},
	aOutMute = {0,0,0,0},
	aOutGain  = {0.0,0.0,0.0,0.0},
	aFlashUint = 0,
	aSourceTrim = {0.0,0.0} -- Analog index 0 , Dante index 1
}

outMute = { -1, -1, -1, -1 }
nOutMeter = { -144.0, -144.0, -144.0, -144.0 }
nChanAlarm = { 0, 0, 0, 0 }
nClipChanAlarm = { 0, 0, 0, 0 }
nSoaChanAlarm = { 0, 0, 0, 0 }
nTempChanAlarm = { 0, 0, 0, 0 }
nVoltChanAlarm = { 0, 0, 0, 0 }
nVoltChanAlarm = { 0, 0, 0, 0 }
nAmpChanAlarm = { 0, 0, 0, 0 }
nAlarm = 0
nFanAlarm = 0
nTempAlarm = 0
nVauxAlarm = 0
nGenericAlarm = 0



ip_default =  "192.168.5.153"
ip =  ip_default
port = 8002
model = "..."
connected = false
connectCounter = 0


--	Escaping data
ESC = "\x1b"
STX = "\x02"
ETX = "\x03"
ESC_ESC = "\x1b\x5b"
STX_ESC = "\x1b\x42"
ETX_ESC = "\x1b\x43"

--	CRC Table data
crc16tab = {
0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50a5, 0x60c6, 0x70e7,
0x8108, 0x9129, 0xa14a, 0xb16b, 0xc18c, 0xd1ad, 0xe1ce, 0xf1ef,
0x1231, 0x0210, 0x3273, 0x2252, 0x52b5, 0x4294, 0x72f7, 0x62d6,
0x9339, 0x8318, 0xb37b, 0xa35a, 0xd3bd, 0xc39c, 0xf3ff, 0xe3de,
0x2462, 0x3443, 0x0420, 0x1401, 0x64e6, 0x74c7, 0x44a4, 0x5485,
0xa56a, 0xb54b, 0x8528, 0x9509, 0xe5ee, 0xf5cf, 0xc5ac, 0xd58d,
0x3653, 0x2672, 0x1611, 0x0630, 0x76d7, 0x66f6, 0x5695, 0x46b4,
0xb75b, 0xa77a, 0x9719, 0x8738, 0xf7df, 0xe7fe, 0xd79d, 0xc7bc,
0x48c4, 0x58e5, 0x6886, 0x78a7, 0x0840, 0x1861, 0x2802, 0x3823,
0xc9cc, 0xd9ed, 0xe98e, 0xf9af, 0x8948, 0x9969, 0xa90a, 0xb92b,
0x5af5, 0x4ad4, 0x7ab7, 0x6a96, 0x1a71, 0x0a50, 0x3a33, 0x2a12,
0xdbfd, 0xcbdc, 0xfbbf, 0xeb9e, 0x9b79, 0x8b58, 0xbb3b, 0xab1a,
0x6ca6, 0x7c87, 0x4ce4, 0x5cc5, 0x2c22, 0x3c03, 0x0c60, 0x1c41,
0xedae, 0xfd8f, 0xcdec, 0xddcd, 0xad2a, 0xbd0b, 0x8d68, 0x9d49,
0x7e97, 0x6eb6, 0x5ed5, 0x4ef4, 0x3e13, 0x2e32, 0x1e51, 0x0e70,
0xff9f, 0xefbe, 0xdfdd, 0xcffc, 0xbf1b, 0xaf3a, 0x9f59, 0x8f78,
0x9188, 0x81a9, 0xb1ca, 0xa1eb, 0xd10c, 0xc12d, 0xf14e, 0xe16f,
0x1080, 0x00a1, 0x30c2, 0x20e3, 0x5004, 0x4025, 0x7046, 0x6067,
0x83b9, 0x9398, 0xa3fb, 0xb3da, 0xc33d, 0xd31c, 0xe37f, 0xf35e,
0x02b1, 0x1290, 0x22f3, 0x32d2, 0x4235, 0x5214, 0x6277, 0x7256,
0xb5ea, 0xa5cb, 0x95a8, 0x8589, 0xf56e, 0xe54f, 0xd52c, 0xc50d,
0x34e2, 0x24c3, 0x14a0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
0xa7db, 0xb7fa, 0x8799, 0x97b8, 0xe75f, 0xf77e, 0xc71d, 0xd73c,
0x26d3, 0x36f2, 0x0691, 0x16b0, 0x6657, 0x7676, 0x4615, 0x5634,
0xd94c, 0xc96d, 0xf90e, 0xe92f, 0x99c8, 0x89e9, 0xb98a, 0xa9ab,
0x5844, 0x4865, 0x7806, 0x6827, 0x18c0, 0x08e1, 0x3882, 0x28a3,
0xcb7d, 0xdb5c, 0xeb3f, 0xfb1e, 0x8bf9, 0x9bd8, 0xabbb, 0xbb9a,
0x4a75, 0x5a54, 0x6a37, 0x7a16, 0x0af1, 0x1ad0, 0x2ab3, 0x3a92,
0xfd2e, 0xed0f, 0xdd6c, 0xcd4d, 0xbdaa, 0xad8b, 0x9de8, 0x8dc9,
0x7c26, 0x6c07, 0x5c64, 0x4c45, 0x3ca2, 0x2c83, 0x1ce0, 0x0cc1,
0xef1f, 0xff3e, 0xcf5d, 0xdf7c, 0xaf9b, 0xbfba, 0x8fd9, 0x9ff8,
0x6e17, 0x7e36, 0x4e55, 0x5e74, 0x2e93, 0x3eb2, 0x0ed1, 0x1ef0
}


--	return CRC16 value for string str of length len 
function crc16(str, len) 
	crc = 0
	for i = 1, len, 1 do 
		crc = (crc16tab[(((crc) >> 8) ~ string.byte(str, i)) + 1] ~ (crc << 8)) & 0xFFFF
	end
	return crc
end

-- Dump function allows inspection of string data packet
function DumpPkt(str, len, bDoPrint)
	dump = "PKT:"
	for i = 1, len, 1 do 
		dump = dump .. string.format("%02x,", str.byte(str, i))
	end
	if (bDoPrint) then print(dump .. "\r") end
	return dump, len
end

function DoUnescaping(str, len)
	out = ""
	count = len;
	bSkip = false;
	for i = 1, len, 1 do 
		if (false == bSkip) then
			checkChar = string.sub(str, i, i)
			if (ESC == checkChar) and (string.len(str) > 1) then
				checkChar = string.sub(str, i, i + 1)
				bSkip = true
				if (ESC_ESC == checkChar) then
					out = out .. ESC
					count = count - 1
				elseif (STX_ESC == checkChar) then
					out = out .. STX
					count = count - 1
				elseif (ETX_ESC == checkChar) then
					out = out .. ETX
					count = count - 1
				else
					print(string.format("Invalid escape sequence at i=%d, count = %d!\r", i, count))
				end
			else
				out = out .. checkChar
			end
		else
			bSkip = false;
		end
	end
	return out, count
end



function ReadResponse(addr, size, data)

	if (0 == size) then
		print(string.format("Read response addr=%X, failed!\r", addr))
		bConnected = false
	else
		if (bPrint) then print(string.format("Read response addr=%X, size = %X\r", addr, size)) end
		if (0x00000000 == addr) then	--	Model
			model = string.sub(data, 1, 0x14)
			if ("DMZO322_ND" == string.sub(model, 1, 10)) then
				model = "Mezzo 322 A"
			elseif ("DMZO322" == string.sub(model, 1, 7)) then
				model = "Mezzo 322 AD"
			elseif ("DMZO324_ND" == string.sub(model, 1, 10)) then
				model = "Mezzo 324 A"
			elseif ("DMZO324" == string.sub(model, 1, 7)) then
				model = "Mezzo 324 AD"
			elseif ("DMZO602_ND" == string.sub(model, 1, 10)) then
				model = "Mezzo 602 A"
			elseif ("DMZO602" == string.sub(model, 1, 7)) then
				model = "Mezzo 602 AD"
			elseif ("DMZOf_ND" == string.sub(model, 1, 10)) then
				model = "Mezzo 604 A"
			elseif ("DMZO604" == string.sub(model, 1, 7)) then
				model = "Mezzo 604 AD"
			end
 		elseif (0x00000014 == addr) then	--	Serial
			serial = string.sub(data, 1, 0x10)
		elseif (0x00000060 == addr) then	--	Version
			version = string.sub(data, 1, 0x14)
		elseif (0x000000F4 == addr) then	--	Name
			name = string.sub(data, 1, 0x50)
		elseif (inputMeterAddress == addr) then	--	Input Meters
			for chan = 1, channels, 1 do
				meterStr = string.sub(data, ((chan - 1) * 4) + 1, chan * 4)
				nVoltPeak = string.unpack("f", meterStr)
				if (0. ~= nVoltPeak) then
					nInMeter[chan] = (math.log(nVoltPeak/8.8, 10) * 20)
				else
					nInMeter[chan] = -192.
				end
				if (bPrint) then print(string.format("In Meter %d = %f dB (%fV)\r", chan, nInMeter[chan], nVoltPeak)) end
			end
		elseif (0xbba8 == addr) then	--	Output Meters
--			data = "abcdefghilmnopqrstuvz"

			for chan = 1, channels, 1 do
				nOutMeter[chan] = -144			
				meterStr = string.sub(data, ((chan - 1) * 4) + 1, chan * 4)
				nVal = string.unpack("f", meterStr)
				nRatio = string.unpack("f", meterStr)

				if (0. ~= nRatio) then
					if (0.0 ~= NamedControl.GetValue("B_MuteO_" ..tostring(chan))) then 
						nOutMeter[chan] = -144
						--print ("in Mute")
					else
						nOutMeter[chan] = -(math.log(nRatio, 10.) * 20)
						--print ("in Log")

					end
				else
					nOutMeter[chan] = 0.
				end
				--NamedControl.SetValue("Meter_output" .. tostring(chan),0)

				--nOutMeter[chan] = -(math.log(nRatio, 10.) * 20.)				if (true) then print(string.format("Out Meter %d = %f dB Ratio = %f, Hex = %X\r", chan, nOutMeter[chan], nRatio, nVal)) end
--				NamedControl.SetValue("Meter_output" .. tostring(chan),nOutMeter[chan])
				--if (true) then print(string.format("Out Meter %d = %f dB Ratio = %f, Hex = %X\r", chan, nOutMeter[chan], nRatio, nVal)) end
				--print(string.format("Meeter result: '%s' \r", DumpPkt(data, string.len( data ), false)))
	
			end

		elseif (0xb63c == addr) then	--	channel alarms
			for chan = 1, channels, 1 do
				nChanAlarm[chan] = 0
			end
			--	Clip
			for chan = 1, channels, 1 do
				nClipChanAlarm[chan] = string.byte(data, 0 + chan)
				if (0 ~= nClipChanAlarm[chan]) then	
					nChanAlarm[chan] = 1
				end
				--nClipChanAlarm[chan] = 1
				if (bPrint) then print(string.format("Clip Alarm %d = %d", chan, nClipChanAlarm[chan])) end
				NamedControl.SetValue("Clip"..tonumber(chan), nClipChanAlarm[chan])
			end
			--	SOA
			for chan = 1, channels, 1 do
				nSoaChanAlarm[chan] = string.byte(data, 4 + chan)
				if (0 ~= nSoaChanAlarm[chan]) then	
					nChanAlarm[chan] = 1
				end
				if (bPrint) then print(string.format("SOA Alarm %d = %d", chan, nSoaChanAlarm[chan])) end

			end
			--	Temp
			for chan = 1, channels, 1 do
				nTempChanAlarm[chan] = string.byte(data, 8 + chan)
				if (0 ~= nTempChanAlarm[chan]) then	
					nChanAlarm[chan] = 1
				end
				--n TempChanAlarm[chan] = 1 .... testing leds
				if (bPrint) then print(string.format("Temp Alarm %d = %d", chan, nTempChanAlarm[chan])) end
				NamedControl.SetValue("Temp"..tonumber(chan), nTempChanAlarm[chan])

			end
			--	Volt
			for chan = 1, channels, 1 do
				nVoltChanAlarm[chan] = string.byte(data, 12 + chan)
				if (0 ~= nVoltChanAlarm[chan]) then	
					nChanAlarm[chan] = 1
				end
				-- nVoltChanAlarm[chan] = 1
				if (bPrint) then print(string.format("Volt Alarm %d = %d", chan, nVoltChanAlarm[chan])) end
				NamedControl.SetValue("Volts"..tonumber(chan), nVoltChanAlarm[chan])

			end
			--	Amp
			for chan = 1, channels, 1 do
				nAmpChanAlarm[chan] = string.byte(data, 16 + chan)
				if (0 ~= nAmpChanAlarm[chan]) then	
					nChanAlarm[chan] = 1
				end
				if (bPrint) then print(string.format("Amp Alarm %d = %d", chan, nAmpChanAlarm[chan])) end
				-- nAmpChanAlarm[chan] = 1
				NamedControl.SetValue("Amps"..tonumber(chan), nAmpChanAlarm[chan])

			end
		elseif (0xb650 == addr) then	--	unit alarms
			nAlarm = 0
			--	Fan
			nFanAlarm = string.byte(data, 1)
			if (0 ~= nFanAlarm) then	
				nAlarm = 1
			end
			-- nFanAlarm = 1
			if (bPrint) then print(string.format("Fan Alarm = %d", nFanAlarm)) end
			NamedControl.SetValue("Fan", nFanAlarm)


			--	Temp
			nTempAlarm = string.byte(data, 2)
			if (0 ~= nTempAlarm) then	
				nAlarm = 1
			end
			-- nTempAlarm = 1
			if (bPrint) then print(string.format("Temp Alarm = %d", nTempAlarm)) end
			NamedControl.SetValue("Temp", nTempAlarm)
			
			--	Vaux
			-- nVauxAlarm = string.byte(data, 5)
			if (0 ~= nVauxAlarm) then	
				nAlarm = 1
			end
			--nVauxAlarm = 1
			if (bPrint) then print(string.format("Vaux Alarm = %d", nVauxAlarm)) end
			NamedControl.SetValue("V aux", nVauxAlarm)
			--	Generic
			nGenericAlarm = string.byte(data, 6)
			if (0 ~= nGenericAlarm) then	
				nAlarm = 1
			end
			-- nGenericAlarm = 1
			if (bPrint) then print(string.format("Generic Alarm = %d", nGenericAlarm)) end
			NamedControl.SetValue("General", nGenericAlarm)
			
		elseif (0xbba0 == addr) then  -- channel'ssignal presence
			for chan = 1, channels, 1 do
			 Signal = string.byte(data,chan )	
			 NamedControl.SetValue("LED_Signal" ..tostring(chan), tonumber(Signal))
			end
		elseif ( 0x2000 == addr) then
			print(string.format("Meeter result: '%s' \r", DumpPkt(data, string.len( data ), false)))				--print(string.format("Meeter result: '%s' \r", DumpPkt(data, string.len( data ), false)))
		--	print(string.format("Meeter result: '%s' \r", DumpPkt(string.sub( data,4,8)), 4, false))				--print(string.format("Meeter result: '%s' \r", DumpPkt(data, string.len( data ), false)))
			bAwait = true -- riabilita le altre reads stoppate precedentemente
			a,b = DumpPkt(data, string.len( data ),true)
			vvv = string.unpack("f",string.sub( data,0,3))
			--print(string.format("Primi quattro: '%s' \r", DumpPkt(string.sub( data,5,8), string.len( 4 ), false)))				--print(string.format("Meeter result: '%s' \r", DumpPkt(data, string.len( data ), false)))
			--vvv = 10. ^ (tonumber(vvv) / 20.)
			print("Aggiornato !!! " .. string.format("%f",tonumber(vvv)))


		else
			print(string.format("Unknown read value addr=%X, size = %X\r", addr, size))
		end
		bConnected = true
	end
end

--	Handle Write response
function WriteResponse(addr, size)
	if (0 == size) then
		print(string.format("Write response addr=%X, failed!\r", addr))
		bConnected = false
	else
		if (bPrint) then print(string.format("Write response addr=%X, size = %X\r", addr, size)) end
		bConnected = true
	end
end




function GotData (udpTable, packet)
	--print("sono in GOTDATA: " )
	
	bValid = true
	responseClicks = 0
	reply = packet.Data
--	print(packet.Data)
	replyLen = string.len(reply)
	--print(string.sub( reply, 20,26))
	if ("DMZO322_ND" == string.sub( reply, 20,26)) then
		model = "Mezzo 322 A"
	elseif ("DMZO322" == string.sub( reply, 20,26)) then
		model = "Mezzo 322 AD"
	elseif ("DMZO324_ND" == string.sub( reply, 20,26)) then
		model = "Mezzo 324 A"
	elseif ("DMZO324" == string.sub( reply, 20,26)) then
		model = "Mezzo 324 AD"
		connected = true
	elseif ("DMZO602_ND" == string.sub( reply, 20,26)) then
		model = "Mezzo 602 A"
	elseif ("DMZO602" == string.sub( reply, 20,26)) then
		model = "Mezzo 602 AD"
	elseif ("DMZO604_ND" == string.sub( reply, 20,26)) then
		model = "Mezzo 604 A"
	elseif ("DMZO604" == string.sub( reply, 20,26)) then
		model = "Mezzo 604 AD"
	end
--	if(model.length > 1) then Connected = true end

	NamedControl.SetText("Model", model)

	if (false) then print(string.format("Rx Pkt: '%s' length %d\r", DumpPkt(reply, replyLen, false))) end


	--	Un-frame and un-escape
	stx = string.sub(reply, 1, 1)
	etx = string.sub(reply, -1, -1)
	if (stx ~= STX) or (etx ~= ETX) then
		bValid = false
--		print(string.format("Invalid start or end byte (%X, %X)!\r", string.byte(stx, 1), string.byte(etx, 1)))
	else
		reply, replyLen = DoUnescaping(reply, replyLen)
	end

	--	Check CRC
	if (true == bValid) then
		crcStr = string.sub(reply, -2, -1)
		crc = string.unpack("<I2", reply)
		crcStr = string.sub(reply, 2, -4)
		crcCalc = crc16(crcStr, string.len(crcStr))
		if (crc ~= crcCalc) then
			bValid = false
			print("CRC doesn't match %X ~= %X!\r", crc, crcCalc)
		else
			reply = crcStr
			replyLen = replyLen - 4
--			print(string.format("Post CRC: '%s' length %d\r", DumpPkt(reply, replyLen, false)))
		end
	end

	--	Check Hdr
	if (true == bValid) then
		magic, protocol, rxTag = string.unpack(">I3<I2<I4", reply)
		if (magic ~= 0x4D5A4F) or (protocol ~= 0x0001) then
			bValid = false
			print(string.format("HDR = %X, %X Should be 0x4D5A4F, 0x0001\r", magic, protocol))
		else
--			print("Header Matches\r")
			if (rxTag ~= lastTag) then
				bValid = false
				print(string.format("Tag = %X, Should be 0x%X\r", rxTag, lastTag))
			else
--				print("Tag Matches\r")
				reply = string.sub(reply, 10)
				replyLen = replyLen - 9
--				print(string.format("Post Hdr: '%s' length %d\r", DumpPkt(reply, replyLen, false)))
			end
		end
	end
		
	-- Process individual command response
	while (true == bValid) and (9 <= replyLen) do
		op, addr, size = string.unpack("<I1<I4<I4", reply)
		if ((0x52 == op) and ((9 + size) <= replyLen)) then 
			--	Read operation
--			print("sono in lettura del response")
			ReadResponse(addr, size, string.sub(reply, 10, 10 + size))
			reply = string.sub(reply, 10 + size)
			replyLen = replyLen - 9 - size
		elseif (0x57 == op) then 
			--	Write operation
			WriteResponse(addr, size)
			reply = string.sub(reply, 10)
			replyLen = replyLen - 9
		elseif (0x45 == op) then 
			--	Erase operation
			EraseResponse(addr, size)
			reply = string.sub(reply, 10)
			replyLen = replyLen - 9
		elseif ((0x43 == op) and ((9 + 2) <= replyLen)) then 
			--	CRC operation
			CrcResponse(addr, size, string.sub(reply, 10 + 2))
			reply = string.sub(reply, 10 + 2)
			replyLen = replyLen - 9 - 2
		else
			print(string.format("Unknown command %d len = %d!\r", op, replyLen))
			break
		end
	end
end

function BuildMultiPacket(tag, cmdTable, cmdLenTable)
	--	tag
	str = string.pack("<I4", tag)
	len = 4

	--	Assemble multicommand
	i = 1
	while (nil ~= cmdTable[1]) and (nil ~= cmdLenTable[i]) do
		str = str .. cmdTable[i]
		len = len + cmdLenTable[i]
		i = i + 1
	end

	crc = crc16(str, len)
	str = str .. string.pack("<I2", crc)
	len =  len + 2

	out = ""
	outLen = len;
	for i = 1, len, 1 do 
		checkChar = string.sub(str, i, i)
		if (ESC == checkChar) then
			out = out .. ESC_ESC
			outLen = outLen + 1
		elseif (STX == checkChar) then
			out = out .. STX_ESC
			outLen = outLen + 1
		elseif (ETX == checkChar) then
			out = out .. ETX_ESC
			outLen = outLen + 1
		else
			out = out .. checkChar
		end
	end

	out = STX .. out .. ETX
	outLen = outLen + 2
	return out, outLen
end


--	Build write command with flexible data type as defined by elementSize, elementFormat and length elementCount
function WriteCmd(addr, data, elementCount, elementSize, elementFormat)
	--	'W' is 0x57
	out = string.pack("<I1<I4<I4", 0x57, addr, elementCount * elementSize)
	for i = 1, elementCount, 1 do
		out = out .. string.pack(elementFormat, data[i])
	end
	return out, 9 + (elementCount * elementSize) 
end


function ReadCmd(addr, elementCount, elementSize)
	--	'R' is 0x52

	out = string.pack("<I1<I4<I4", 0x52, addr, elementCount * elementSize)
	--print ("out: "..out)
	return out, 9
	
end

function SetTrimAnalogDante(Addr)
	cmd = {}	
	cmdLen = {}
	val = {}
	ControlName = "           "
	ControlName1 = "           "
	-- select digital or analog
	if (Addr == 0x2000) then  
		SourceIndex = 0
		ControlName = "F_InputGain1" 
		ControlName1 = "P_InputGain1" 
	else
		SourceIndex = 1
		ControlName = "F_InputGain2"
		ControlName1 = "P_InputGain2" 
	end
	-- any user change ?, if not, do nothing
	if(actionStatus.aSourceTrim[SourceIndex] == NamedControl.GetValue(ControlName) ) then 	
		--	il valore non è cambiato, quindi non fare niente
				return 
			end
	-- If the User has changed the control status, let's remember it
	actionStatus.aSourceTrim[SourceIndex] = NamedControl.GetValue(ControlName)
	
	print(ControlName)
	v = NamedControl.GetValue(ControlName)
	print(string.format("%d",v))	
	if(v == nill)then return end

	NamedControl.SetText(ControlName1,v)
	val[1] = 10. ^ (tonumber(v) / 20.)				
	cmd[1], cmdLen[1] = WriteCmd(Addr + 0,val, 1, 4, "f") -- Write Input Mute if changed
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd) 	 		
end	

function ReadTrimAnalogDante(Addr)
	cmd = {}	
	cmdLen = {}
	val = {}
	print("Trim Read !!!")
	cmd[1], cmdLen[1] = ReadCmd(0x2000, 4, 4) -- Write Input Mute if changed
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd) 	 			
end	


function SetSourceGain(SoucrceNumber,GainNumber,Value)
	cmd = {}	
	cmdLen = {}

	GainControlName = ("F_M" ..tostring(SoucrceNumber+((GainNumber-1)*4)))

	NamedControl.SetValue(GainControlName,Value)

	if(actionStatus.aGain[SoucrceNumber][GainNumber] == NamedControl.GetValue(GainControlName) ) then 	
	--	print("il valore non è cambiato: "..GainControlName)
		
 		return end



--	print("Il Valore è cambiato: "..GainControlName)
	-- value remainder
	actionStatus.aGain[SoucrceNumber][GainNumber] = NamedControl.GetValue(GainControlName) 
	v =actionStatus.aGain[SoucrceNumber][GainNumber]
--	print ("Gain Control Value: ",actionStatus.aGain[SoucrceNumber][GainNumber])

	val[1] = 10. ^ (tonumber(v) / 20.)
	NamedControl.GetPosition("F_M1")
	cmd[1], cmdLen[1] = WriteCmd(0x3018 + ((SoucrceNumber-1)*16)  + (GainNumber-1)*4,val, 1, 4, "f") 
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd) 	 		
end

function SourceGain(SoucrceNumber,GainNumber)
	cmd = {}	
	cmdLen = {}
	GainControlName = ("F_M" ..tostring(SoucrceNumber+((GainNumber-1)*4)))

	if(actionStatus.aGain[SoucrceNumber][GainNumber] == NamedControl.GetValue(GainControlName) ) then 	
	--	print("il valore non è cambiato: "..GainControlName)
		
 		return end



	--print("Il Valore è cambiato: "..GainControlName)
	-- value remainder
	actionStatus.aGain[SoucrceNumber][GainNumber] = NamedControl.GetValue(GainControlName) 
	v =actionStatus.aGain[SoucrceNumber][GainNumber]
	--print ("Gain Control Value: ",actionStatus.aGain[SoucrceNumber][GainNumber])

	val[1] = 10. ^ (tonumber(v) / 20.)
	NamedControl.GetPosition("F_M1")
	cmd[1], cmdLen[1] = WriteCmd(0x3018 + ((SoucrceNumber-1)*16)  + (GainNumber-1)*4,val, 1, 4, "f") 
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd) 	 		
end

function SourceMute (SoucrceNumber,GainNumber)
	cmd = {}	
	cmdLen = {}
	GainControlName = ("B_MuteM_" ..tostring(SoucrceNumber+((GainNumber-1)*4)))

	if(actionStatus.aMute[SoucrceNumber] == NamedControl.GetValue(GainControlName) ) then 	
	--	print("il valore non è cambiato: "..GainControlName)
		
 		return end

	--print("Il Valore è cambiato: "..GainControlName)
	-- value remainder
	actionStatus.aMute[SoucrceNumber] = NamedControl.GetValue(GainControlName) 
	v =actionStatus.aMute[SoucrceNumber]

	--print ("Gain Control Value: ",actionStatus.aMute[SoucrceNumber])

	val[1] = v
	NamedControl.GetPosition("F_M1")
	--cmd[1], cmdLen[1] = WriteCmd(0x3058 + 0,val, 1, 1, ">I1")
	--
	cmd[1], cmdLen[1] = WriteCmd(0x3058 + SoucrceNumber-1 +(GainNumber-1),val, 1, 1, ">I1")
	-- cmd[1], cmdLen[1] = WriteCmd(0x3018 + ((SoucrceNumber-1)*16)  + (GainNumber-1)*4,val, 1, 4, "f") 
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd) 	 		
end


function SourceAnalogOrDante(OutNumber)

	cmd = {}
	cmdLen = {}

	-- get control name
--	OutName = "B_MuteO_" ..tostring(OutNumber)
	--print(" Il Nome dell'output è: " ..OutName)

--	if(actionStatus.aOutMute[OutNumber-1] == NamedControl.GetValue(OutName) ) then 	
		--	print("il valore non è cambiato: "..GainControlName)
			
--			 return end
	
--			 actionStatus.aOutMute[OutNumber-1] = NamedControl.GetValue(OutName) 
print("ksksksk")
	val = {}

	val[1] = 2
	--	cmd[1], cmdLen[1] = WriteCmd(0x2200 + OutNumber-1,val, 1, 1, ">I1") -- Write Input Mute if changed

	cmd[1], cmdLen[1] = WriteCmd(0x2210,val, 1, 1, ">I1") -- Write Input Mute if changed
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	if (true) then print(string.format("..... Timer Tx: '%s' length %d\r",  DumpPkt(cmd, cmdLen, false))) end
	MezzoU:Send(ip, port, cmd)


end


function SourceAnalogOrDante1(OutNumber)

	cmd = {}
	cmdLen = {}

print("ksksksk")
	val = {}

	val[1] = 2
	--	cmd[1], cmdLen[1] = WriteCmd(0x2200 + OutNumber-1,val, 1, 1, ">I1") -- Write Input Mute if changed

	cmd[1], cmdLen[1] = WriteCmd(0x2220,val, 1, 1, ">I1") -- Write Input Mute if changed
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	if (true) then print(string.format("..... Timer Tx: '%s' length %d\r",  DumpPkt(cmd, cmdLen, false))) end
	MezzoU:Send(ip, port, cmd)


end

function Standby ()
	cmd = {}	
	cmdLen = {}

	val[1] = 0

	cmd[1], cmdLen[1] = WriteCmd(0xa000,val, 1, 1, ">I4")

	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	print("mando la standby !!!")
	MezzoU:Send(ip, port, cmd) 	 		
end


function OutputMute(OutNumber)

	cmd = {}
	cmdLen = {}

	-- get control name
	OutName = "B_MuteO_" ..tostring(OutNumber)
	--print(" Il Nome dell'output è: " ..OutName)

	if(actionStatus.aOutMute[OutNumber-1] == NamedControl.GetValue(OutName) ) then 	
		--	print("il valore non è cambiato: "..GainControlName)
			
			 return end
	
			 actionStatus.aOutMute[OutNumber-1] = NamedControl.GetValue(OutName) 
	val = {}	
	val[1] = NamedControl.GetValue(OutName)
	cmd[1], cmdLen[1] = WriteCmd(0x4024 + OutNumber-1,val, 1, 1, ">I1") -- Write Input Mute if changed
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	--if (bPrint or (0~=nFlashCount)) then print(string.format("Timer Tx: '%s' length %d\r",  DumpPkt(cmd, cmdLen, false))) end
	MezzoU:Send(ip, port, cmd)


end

function OutputGain(OutNumber)
	cmd = {}
	cmdLen = {}
		val = {}
	
	OutName = "F_Output" ..tostring(OutNumber)


	if(actionStatus.aOutGain[OutNumber-1] == NamedControl.GetValue(OutName) ) then 	
		--	print("il valore non è cambiato: "..GainControlName)
			
			 return end

	
	actionStatus.aOutGain[OutNumber-1] = NamedControl.GetValue(OutName)

	v = tonumber(NamedControl.GetValue(OutName))

	print(OutName .. " Value is: ".. v)
	val[1] = 10. ^ (tonumber(v) / 20.)
	print(string.format( "%x", 0x4000 + ((OutNumber-1)*4)))
	cmd[1], cmdLen[1] = WriteCmd(0x4000 + ((OutNumber-1)*4),val, 1, 4, "f") -- Write Input Mute if changed
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd)

end


function FlashUnit()
	cmd = {}
	cmdLen = {}

	
	if(actionStatus.aFlashUint == NamedControl.GetValue("Identify Button") ) then 	
		--	il valore non è cambiato, quindi non fare niente
				return 
			end
	-- If the User has changed the control status, then remember the currente status
	actionStatus.aFlashUint = NamedControl.GetValue("Identify Button")
	NamedControl.SetValue("Identify Button",0)
	v = NamedControl.GetValue("Identify Button")
	val = {}	--	temporary work value, must be initialized as table	
	
	val[1] = 1--tonumber(v)
	print("falsh send ...")
	
	 cmd[1], cmdLen[1] = WriteCmd(0x100000, val, 1, 1, ">I1")	--	read unit alarms
	 cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	 if (true) then print(string.format("..... FLASH Tx: '%s' length %d\r",  DumpPkt(cmd, cmdLen, false))) end
	 MezzoU:Send(ip, port, cmd)	
end

--************************ Read Channels Allarm Request *****************
function ReadChannelsAllarm()
	cmd = {}
	cmdLen = {}

	cmd[1], cmdLen[1] = ReadCmd(0xb63c, 20, 1)	--	Read allarm,
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	--print(tostring(cmd) .. " - " .. tostring(cmdLen) )
	
	
	
	MezzoU:Send(ip, port, cmd)
					--	Output Meters
	

end


--************************ Read Channels Allarm Request *****************
function ReadSignalPresence(Chan)
	cmd = {}
	cmdLen = {}

	cmd[1], cmdLen[1] = ReadCmd(0xbba0, 4, 1)	--	Read allarm,
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)

	MezzoU:Send(ip, port, cmd)
end



--************************ Read Unit Allarm Request *****************
function ReadUnitAllarm()
	cmd = {}
	cmdLen = {}

	cmd[1], cmdLen[1] = ReadCmd(0xb650, 6, 1)	--	Read allarm,
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd)
	

end


--************************ Read Outputs Meeter Request *****************
function ReadOutputMeeter(OutNumber)
	cmd = {}
	cmdLen = {}
	-- ****************** lettura meeter
	cmd[1], cmdLen[1] = ReadCmd(0xbba8, 4, 4)
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	
	MezzoU:Send(ip, port, cmd)
					--	Output Meters
end


--******************** Read Model Request Function *****************
function ReadModel()

print("................. READ MODEL ................")
	cmd = {}
	cmdLen = {}
	-- ****************** lettura modello 
	cmd[1], cmdLen[1] = ReadCmd(0x0, 0x14, 1)	--	Read Model	
	cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	--print(tostring(cmd) .. " - " .. tostring(cmdLen) )
	
	--print (ip,port)
	
	MezzoU:Send(NamedControl.GetText("I_IP"), port, cmd)
--[[
	cmd = {}
	cmdLen = {}
	cmd[1], cmdLen[1] = ReadCmd(0xb650, 6, 1)	--	read unit alarms

	MezzoU:Send(ip, port, cmd)
	]]
end


function AutoConnect()
  
    IP = NamedControl.GetText("I_IP")
    if NamedControl.GetPosition("B_Auto_Connect") == 1 then

        if connected == false then
            connectCounter = connectCounter + 1
            if connectCounter == 4 then
                print("Not Connected")
                MezzoU:Open(Device.LocalUnit.ControlIP,Port)   
				ReadModel()
                connectCounter = 0
                print ( "Try Autoconnection ")
            end
        end
    end
end

function AllarmCheck(Channel)
	if bAwait then
		ReadChannelsAllarm()
		ReadUnitAllarm()
		ReadOutputMeeter(Channel)
	end
end
-- ****************** Check and set connection ******************
function Connect()

	if (NamedControl.GetValue("B_Connect") == 1) --bottone Connect 
    then 
        if ( "" == NamedControl.GetText("I_IP") )
        then 
           NamedControl.SetText("I_IP", ip_default ) --inserisci controlli sintassi ip   
             
        end
		MezzoU:Open(Device.LocalUnit.ControlIP,Port)   
		receivedIP, receivedPort = MezzoU:GetSockName()
		print("IP: " .. receivedIP .. " Port: " .. receivedPort .. " Offline: " .. tostring(Device.Offline))
		ReadModel()
	--	Standby()
--		SourceAnalogOrDante(1)   
--		SourceAnalogOrDante1(1)
		--OutputMeeter(1)
		--FlashUnit()
    end 
	if(connected) then 
		NamedControl.SetValue("LED_Connect", 1)
	else 
		NamedControl.SetValue("LED_Connect", 0)
	end
	NamedControl.SetValue("B_Connect",0)
	
end


function Disconnect()
	if (NamedControl.GetValue("B_Disconnect") == 1) --bottone Connect 
	then
		MezzoU:Close()
		connected = false
	end
	NamedControl.SetValue("B_Disconnect",0)
end

function Preset1()
	n = 1
	for n = 1,16,1 do
		NamedControl.SetValue("B_MuteM_" .. tostring(n), 0)
	end
	for nSource = 1, 4, 1 do
		for nGain = 1, 4, 1 do
			if(nSource == 1) then
				SetSourceGain(nSource,nGain,0)
			else
				SetSourceGain(nSource,nGain,-60)
			end
			SourceGain(nSource,nGain)
			n = n+1
		end
		n= n+1
	end
end

function Preset2()
	n = 1
	for n = 1,16,1 do
		NamedControl.SetValue("B_MuteM_" .. tostring(n), 0)
	end
	
	for nSource = 1, 4, 1 do
		for nGain = 1, 4, 1 do

				SetSourceGain(nSource,nGain,-60)
			n = n+1
		end
		n= n+1
	end
	
	SetSourceGain(1,1,0)
	SetSourceGain(2,2,0)
	SetSourceGain(3,3,0)
	SetSourceGain(4 ,4,0)	
end

function Preset3()
	n = 1
	for n = 1,16,1 do
		NamedControl.SetValue("B_MuteM_" .. tostring(n), 0)
	end
	for nSource = 1, 4, 1 do
		for nGain = 1, 4, 1 do
			if(nSource == 2) then
				SetSourceGain(nSource,nGain,0)
			else
				SetSourceGain(nSource,nGain,-60)
			end
			SourceGain(nSource,nGain)
			n = n+1
		end
		n= n+1
	end
end

function Preset4()
	n = 1
	for n = 1,16,1 do
		NamedControl.SetValue("B_MuteM_" .. tostring(n), 0)
	end
	
	for nSource = 1, 4, 1 do
		for nGain = 1, 4, 1 do

				SetSourceGain(nSource,nGain,-60)
			n = n+1
		end
		n= n+1
	end
end


function TimerClick()

--	print("Analog Trim Value: " ..NamedControl.GetPosition("F_InputGain2"))
--	NamedControl.SetText("P_InputGain1",tostring(NamedControl.GetValue("F_InputGain1")))
	AutoConnect()
	Connect()
	Disconnect()

	CheckSync()

	SetTrimAnalogDante(0x2000)
	SetTrimAnalogDante(0x2008)
	
	-- **************** Matrix source Gain Managment
	for nSource = 1, 4, 1 do
		for nGain = 1, 4, 1 do
			SourceGain(nSource,nGain)
		end
	end
	-- *************** Matrix Source Mute Managment
	for nSource = 1, 16, 1 do
		SourceMute(nSource,1)
		
	end

	for i = 1,4,1
	do
		OutputMute(i)
		OutputGain(i)
		if((Tick % 3) == 0)
		then
		--	AllarmCheck(i)
		end
	end

	-- da rivedere
	if(false)
	then
		MezzoU:Close()
		MezzoU:Open(Device.LocalUnit.ControlIP,Port)   
	end
	
	NamedControl.SetValue("Meter_output1", nOutMeter[1])
	NamedControl.SetValue("Meter_output2", nOutMeter[2])
	NamedControl.SetValue("Meter_output3", nOutMeter[3])
	NamedControl.SetValue("Meter_output4", nOutMeter[4])
	ReadSignalPresence(0)

	Tick = Tick + 1
	if 1 == NamedControl.GetValue("B_M_Preset1") then
		NamedControl.SetValue("B_M_Preset1", 0)
		Preset1()
	end
	if 1 == NamedControl.GetValue("B_M_Preset2") then
		NamedControl.SetValue("B_M_Preset2", 0)
		Preset2()
	end
	if 1 == NamedControl.GetValue("B_M_Preset3") then
		NamedControl.SetValue("B_M_Preset3", 0)
		Preset3()
	end
	if 1 == NamedControl.GetValue("B_M_Preset4") then
		NamedControl.SetValue("B_M_Preset4", 0)
		Preset4()
	end

	FlashUnit()
	
end


function CheckSync()

	if 1 == NamedControl.GetValue("B_Sinc") then
		bAwait = false
		
		ReadTrimAnalogDante(0x2000)
		NamedControl.SetValue("B_Sinc", 0)
		return true
	end
	return false
end

print("start !!!!!!")
--	Open UDP port
MezzoU = UdpSocket.New()

MezzoU:Open(Device.LocalUnit.ControlIP,0)
MezzoU.Data = GotData

-- Force connect offline to off each load.
NamedControl.SetValue("Connect Offline" , 0.0) 

--Device.Offline = false


--[[

--****************************** Output Mute ***************************
cmd = {}
cmdLen = {}


val = {}	--	temporary work value, must be initialized as table	
val[1] = 1
cmd[1], cmdLen[1] = WriteCmd(0x4024 + 0,val, 1, 1, ">I1") -- Write Input Mute if changed
cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)

--MezzoU:Send(ip, port, cmd)
--MezzoU:Send(ip, 8002, "02,00,00,34,12,52,00,00,00,00,14,00,00,00,52,14,00,00,00,10,00,00,00,52,60,00,00,00,14,00,00,00,52,f4,00,00,00,50,00,00,00,57,00,30,00,00,04,00,00,00,01,00,00,00,57,04,30,00,00,01,00,00,00,01,57,08,30,00,00,04,00,00,00,93,8c,d5,40,57,05,30,00,00,01,00,00,00,01,57,0c,30,00,00,04,00,00,00,9f,b3,53,3c,57,06,30,00,00,01,00,00,00,01,57,10,30,00,00,04,00,00,00,b1,50,a4,3d,57,07,30,00,00,01,00,00,00,01,57,14,30,00,00,04,00,00,00,00,00,80,3f,52,40,ba,00,00,10,00,00,00,6c,64,03")
--****************************** Output Mute ***************************
cmd = {}
cmdLen = {}

--****************************** Matrix source 1 input 1 mute
val = {}	--	temporary work value, must be initialized as table	
val[1] = 1
cmd[1], cmdLen[1] = WriteCmd(0x3058 + 0,val, 1, 1, ">I1") -- Write Input Mute if changed
cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)

--MezzoU:Send(ip, port, cmd)


cmd = {}
cmdLen = {}

--******************************  source 1 input 1 Gain
val = {}	--	temporary work value, must be initialized as table	
val[1] = 15.
cmd[1], cmdLen[1] = WriteCmd(0x3008 + 0,val, 1, 4, "f") -- Write Input Mute if changed
cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)

MezzoU:Send(ip, port, cmd)

cmd = {}
cmdLen = {}
inGain = { -60.0, -40.0, -10,-0.0 }
--******************************  source 1 input 1 Gain
val = {}	--	temporary work value, must be initialized as table	
print("Gain is:" ..inGain[1] .."\n\r"
.. tostring( 10. ^ (inGain[1] / 20.)) .."\n\r"
.. tostring( 10. ^ (inGain[2] / 20.)) .."\n\r"
.. tostring( 10. ^ (inGain[3] / 20.)) .."\n\r"
.. tostring( 10. ^ (inGain[4] / 20.)) .."\n\r"
)
val[1] = 10. ^ (inGain[1] / 20.)
cmd[1], cmdLen[1] = WriteCmd(0x3018 + 0,val, 1, 4, "f") -- Write Input Mute if changed
cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
--MezzoU:Send(ip, port, cmd)

cmd = {}
cmdLen = {}

val[1] = 10. ^ (inGain[2] / 20.)
cmd[1], cmdLen[1] = WriteCmd(0x301c + 0,val, 1, 4, "f") -- Write Input Mute if changed
cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
--MezzoU:Send(ip, port, cmd)

cmd = {}
cmdLen = {}

val[1] = 10. ^ (inGain[3] / 20.)
cmd[1], cmdLen[1] = WriteCmd(0x3020 + 0,val, 1, 4, "f") -- Write Input Mute if changed
cmd, cmdLen			 = BuildMultiPacket(0, cmd, cmdLen)	
--MezzoU:Send(ip, port, cmd)
	
cmd = {}	
cmdLen = {}


v = NamedControl.GetValue("F_M1")
v1 = 60 - (tonumber(v) * -60.0)
print ("---------------	-  	------------- %f",v1,tonumber(v))

		gain1 =  10. ^ (v1 / 20.)	
print(gain1)


val[1] = 10. ^ (tonumber(v) / 20.)
--val[1]=  10. ^ (inGain[4] / 20.)				
cmd[1], cmdLen[1] = WriteCmd(0x3024 + 0,val, 1, 4, "f") -- Write Input Mute if changed
cmd, cmdLen = BuildMultiPacket(0, cmd, cmdLen)
	MezzoU:Send(ip, port, cmd) 	 		

]]

	

function Init()
	for nSource = 1, 4, 1 do
		actionStatus.aGain[nSource] = {}   
		for nGain = 1, 4, 1 do
			actionStatus.aGain[nSource][nGain] = -60
		end
	end
	for nSource = 1, 16, 1 do
		actionStatus.aMute[nSource] = 0   
	end
end

Init()

NamedControl.SetText("Model", model)

MyTimer = Timer.New()
MyTimer.EventHandler = TimerClick
MyTimer:Start(.25)


--Standby()
--SourceAnalogOrDante(1)

--GetSourceGain(1,1)
--SourceMute(4,1)


