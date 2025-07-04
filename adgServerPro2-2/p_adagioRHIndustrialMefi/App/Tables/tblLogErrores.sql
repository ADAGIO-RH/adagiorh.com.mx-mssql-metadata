USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [App].[tblLogErrores](
	[IDLogError] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NULL,
	[Fecha] [datetime] NOT NULL,
	[ProcedureName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ErrorNumber] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ErrorSeverity] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ErrorState] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ErrorLine] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ErrorMessage] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_AppTblLogErrores_IDLogError] PRIMARY KEY CLUSTERED 
(
	[IDLogError] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
