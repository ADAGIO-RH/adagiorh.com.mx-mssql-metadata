USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblCatConfigEmpresa28032025](
	[IDConfigEmpresa] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[Usuario] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Password] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[PasswordKey] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Token] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TieneCertificado] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
