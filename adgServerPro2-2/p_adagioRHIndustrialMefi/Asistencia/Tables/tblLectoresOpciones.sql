USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Asistencia].[tblLectoresOpciones](
	[IDLectorOpcion] [int] IDENTITY(1,1) NOT NULL,
	[IDLector] [int] NOT NULL,
	[DevSN] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DeviceName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AttLogStamp] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[OperLogStamp] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[AttPhotoStamp] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ErrorDelay] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Delay] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TransFlag] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Realtime] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TransInterval] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TransTimes] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Encrypt] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[LastRequestTime] [datetime] NULL,
	[IPAddress] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MAC] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FWVersion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UserCount] [int] NULL,
	[FpCount] [int] NULL,
	[AttCount] [int] NULL,
	[TimeZone] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Timeout] [int] NULL,
	[SyncTime] [int] NULL,
	[OEMVendor] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IRTempDetectionFunOn] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaskDetectionFunOn] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[UserPicURLFunOn] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioDataSupport] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioPhotoSupport] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioVersion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MultiBioCount] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaxMultiBioDataCount] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[MaxMultiBioPhotoCount] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AsistenciatblLectoresOpciones_IDLectorOpcion] PRIMARY KEY CLUSTERED 
(
	[IDLectorOpcion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Asistencia].[tblLectoresOpciones]  WITH CHECK ADD  CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTblLectoresOpciones_IDLector] FOREIGN KEY([IDLector])
REFERENCES [Asistencia].[tblLectores] ([IDLector])
GO
ALTER TABLE [Asistencia].[tblLectoresOpciones] CHECK CONSTRAINT [FK_AsistenciaTblLectores_AsistenciaTblLectoresOpciones_IDLector]
GO
