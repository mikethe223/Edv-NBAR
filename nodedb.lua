--[[
color palette (by category in rgb)
0.5 0.9 0.3 - inputs
0.8 0.1 0.8 - effects
0.4 0.9 0.9 - converter
]]--
return function(nodemgr,addNode)

    -- EFFECTS

    local monoNTSCNoiseNode = table.shallow_copy(nodemgr.nodeClass)
    monoNTSCNoiseNode.title="Monochrome noise [ANALOG]"
    monoNTSCNoiseNode.shortTitle="Monochrome noise [A]"
    monoNTSCNoiseNode.id="ntsc-mchrome-noise"
    monoNTSCNoiseNode.about="Adds monochrome noise to an analog video signal."
    monoNTSCNoiseNode.inputs={nodemgr.ioElem.avideo}
    monoNTSCNoiseNode.outputs={nodemgr.ioElem.avideo}
    monoNTSCNoiseNode.color={0.8,0.1,0.8,0.2}
    addNode(monoNTSCNoiseNode)

    local NTSCEQNode = table.shallow_copy(nodemgr.nodeClass)
    NTSCEQNode.title="Equalizer [ANALOG]"
    NTSCEQNode.shortTitle="Equalizer [A]"
    NTSCEQNode.id="ntsc-equalizer"
    NTSCEQNode.about="Changes the volume of select frequencies."
    NTSCEQNode.inputs={nodemgr.ioElem.avideo}
    NTSCEQNode.outputs={nodemgr.ioElem.avideo}
    NTSCEQNode.color={0.8,0.1,0.8,0.2}
    addNode(NTSCEQNode)

    -- INPUTS

    local videoInputNode = table.shallow_copy(nodemgr.nodeClass)
    videoInputNode.title="Video input [DIGITAL]"
    videoInputNode.shortTitle="Video input [D]"
    videoInputNode.id="digital-video-input"
    videoInputNode.about="Generates a digital signal from a video file."
    videoInputNode.outputs={nodemgr.ioElem.digital}
    videoInputNode.color={0.5,0.9,0.3,0.2}
    function videoInputNode.configure(screenNode)
        -- screenNode.contentFile
    end
    addNode(videoInputNode)

    local audioInputNode = table.shallow_copy(nodemgr.nodeClass)
    audioInputNode.title="Audio input [DIGITAL]"
    audioInputNode.shortTitle="Audio input [D]"
    audioInputNode.id="digital-audio-input"
    audioInputNode.about="Generates a digital signal from an audio file."
    audioInputNode.outputs={nodemgr.ioElem.digital}
    audioInputNode.color={0.5,0.9,0.3,0.2}
    addNode(audioInputNode)

    local AVInputNode = table.shallow_copy(nodemgr.nodeClass)
    AVInputNode.title="Audio-video input [DIGITAL]"
    AVInputNode.shortTitle="A-V input [D]"
    AVInputNode.id="digital-audiovideo-input"
    AVInputNode.about="Generates a digital video signal (node 1) and a digital audio signal (node 2) from a video file."
    AVInputNode.outputs={nodemgr.ioElem.digital,nodemgr.ioElem.digital}
    AVInputNode.color={0.5,0.9,0.3,0.2}
    addNode(AVInputNode)

    -- CONVERTERS

    local digitalToNTSCNode = table.shallow_copy(nodemgr.nodeClass)
    digitalToNTSCNode.title="[DIGITAL] video to [ANALOG]"
    digitalToNTSCNode.shortTitle="[D] video to [A]"
    digitalToNTSCNode.id="dvideo-to-ntsc"
    digitalToNTSCNode.about="Converts a digital video signal to a (raw) analog signal."
    digitalToNTSCNode.inputs={nodemgr.ioElem.digital}
    digitalToNTSCNode.outputs={nodemgr.ioElem.avideo}
    digitalToNTSCNode.color={0.4,0.9,0.9,0.2}
    addNode(digitalToNTSCNode)

    local NTSCToDigitalNode = table.shallow_copy(nodemgr.nodeClass)
    NTSCToDigitalNode.title="[ANALOG] to [DIGITAL] video"
    NTSCToDigitalNode.shortTitle="[A] to [D] video"
    NTSCToDigitalNode.id="ntsc-to-dvideo"
    NTSCToDigitalNode.about="Converts a (raw) analog signal to a digital video signal."
    NTSCToDigitalNode.inputs={nodemgr.ioElem.avideo}
    NTSCToDigitalNode.outputs={nodemgr.ioElem.digital}
    NTSCToDigitalNode.color={0.4,0.9,0.9,0.2}
    addNode(NTSCToDigitalNode)

    -- OTHER

    local output = table.shallow_copy(nodemgr.nodeClass)
    output.title="Output [DIGITAL]"
    output.shortTitle="Out [D]"
    output.id="output"
    output.about="Outputs a digital video signal."
    output.inputs={nodemgr.ioElem.digital}
    output.color={0.5,0.5,0.5,0.2}
    addNode(output)
end
