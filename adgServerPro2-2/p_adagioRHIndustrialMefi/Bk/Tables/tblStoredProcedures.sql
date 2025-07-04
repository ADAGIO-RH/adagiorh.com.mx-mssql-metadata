USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblStoredProcedures](
	[IDStoredProcedure] [int] IDENTITY(1,1) NOT NULL,
	[Definition] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[NombreSP] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[BKID] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaCreacion] [datetime] NULL,
	[Type] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_BkTblStoredProcedures_IDStoredProcedure] PRIMARY KEY CLUSTERED 
(
	[IDStoredProcedure] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Bk].[tblStoredProcedures] ADD  CONSTRAINT [D_BkTblStoredProcedures_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
