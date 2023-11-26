USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [IMSS].[tblCatMotivoBaja](
	[IDMotivoBaja] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_IMSSTblCatMotivoBaja_IDMotivoBaja] PRIMARY KEY CLUSTERED 
(
	[IDMotivoBaja] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
