USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[TblTimbrado02052025](
	[IDTimbrado] [int] IDENTITY(1,1) NOT NULL,
	[IDHistorialEmpleadoPeriodo] [int] NOT NULL,
	[IDTipoRegimen] [int] NOT NULL,
	[UUID] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ACUSE] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDEstatusTimbrado] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[Actual] [bit] NULL,
	[IDUsuario] [int] NULL,
	[CodigoError] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Error] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SelloCFDI] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[SelloSAT] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CadenaOriginal] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[NoCertificadoSat] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CustomID] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
