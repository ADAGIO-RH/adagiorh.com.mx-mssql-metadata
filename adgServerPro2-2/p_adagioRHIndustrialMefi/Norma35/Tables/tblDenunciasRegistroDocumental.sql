USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblDenunciasRegistroDocumental](
	[IDDenunciasRegistroDocumental] [int] IDENTITY(1,1) NOT NULL,
	[IDDenuncia] [int] NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ContentType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Data] [varbinary](max) NOT NULL,
 CONSTRAINT [Pk_tblDenunciasRegistroDocumental_IDDenunciasRegistroDocumental] PRIMARY KEY CLUSTERED 
(
	[IDDenunciasRegistroDocumental] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblDenunciasRegistroDocumental]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblDenunciasRegistroDocumental_Norma35TblDenuncias_IDDenuncia] FOREIGN KEY([IDDenuncia])
REFERENCES [Norma35].[tblDenuncias] ([IDDenuncia])
GO
ALTER TABLE [Norma35].[tblDenunciasRegistroDocumental] CHECK CONSTRAINT [FK_Norma35TblDenunciasRegistroDocumental_Norma35TblDenuncias_IDDenuncia]
GO
